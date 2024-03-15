defmodule Short.Counters.Counter do
  @moduledoc false
  @behaviour GenServer

  alias Short.Counters.CounterSupervisor
  alias Short.Counters.UniqueRegistry
  alias Short.ShortenedLinks.ShortLink

  require Logger

  defstruct short_link: nil,
            slug: nil,
            counter: 0,
            context_mod: nil,
            timer_ref: nil

  @type t() :: %__MODULE__{
          short_link: ShortLink.t() | nil,
          slug: Short.ShortenedLinks.Slug.t(),
          counter: non_neg_integer(),
          context_mod: module(),
          timer_ref: nil | reference()
        }

  # INITIALIZATION

  @type slug :: Short.ShortenedLinks.Slug.t()

  @spec child_spec(slug() | ShortLink.t() | {slug() | ShortLink.t(), opts :: Keyword.t() | map()}) ::
          Supervisor.child_spec()
  def child_spec(slug) when is_binary(slug) do
    child_spec({slug, []})
  end

  def child_spec(%ShortLink{} = short_link), do: child_spec({short_link, []})

  def child_spec({%ShortLink{slug: slug} = short_link, opts}) do
    opts = Enum.into(opts, %{context_mod: Short.ShortenedLinks})

    %{
      id: {slug, __MODULE__},
      start: {__MODULE__, :start_link, [short_link, opts]},
      restart: :transient
    }
  end

  def child_spec({slug, opts}) when is_binary(slug) do
    opts = Enum.into(opts, %{context_mod: Short.ShortenedLinks})

    %{
      id: {slug, __MODULE__},
      start: {__MODULE__, :start_link, [slug, opts]},
      restart: :transient
    }
  end

  def child_spec(_bad_args), do: raise(ArgumentError, "Slug or ShortLink required")

  def start_link(extras, slug_or_short_link, init_opts) do
    # Called when `:extra_arguments` is used by `DynamicSupervisor`
    start_link(slug_or_short_link, Enum.into(extras, init_opts))
  end

  @spec start_link(slug() | ShortLink.t(), init_opts :: map()) :: GenServer.on_start()
  def start_link(%ShortLink{slug: slug} = short_link, init_opts) do
    init_struct = %{struct(__MODULE__, init_opts) | slug: slug, short_link: short_link}
    GenServer.start_link(__MODULE__, init_struct, name: name(slug, init_opts))
  end

  def start_link(slug, init_opts) do
    init_struct = %{struct(__MODULE__, init_opts) | slug: slug}
    GenServer.start_link(__MODULE__, init_struct, name: name(slug, init_opts))
  end

  @impl GenServer
  @spec init(t()) :: {:ok, t()} | {:ok, t(), {:continue, {:hydrate_state, slug()}}}
  def init(%__MODULE__{} = init_state) do
    if init_state.short_link do
      {:ok, %{init_state | counter: 0}}
    else
      {:ok, init_state, {:continue, {:hydrate_state, init_state.slug}}}
    end
  end

  # CLIENT API

  def find_or_start(slug_or_short_link, scope \\ %{}) do
    sup_name = CounterSupervisor.name(scope)

    case CounterSupervisor.start_child(sup_name, {slug_or_short_link, scope}) do
      {:ok, child} -> child
      {:ok, child, _info} -> child
      {:error, {:already_started, child}} -> child
      other -> log_start_error(other, slug_or_short_link, scope)
    end
  end

  @doc "Gets the current count of the given slug."
  @spec get(pid() | slug() | ShortLink.t()) :: non_neg_integer()
  def get(pid) when is_pid(pid), do: GenServer.call(pid, :get)
  def get(scope), do: GenServer.call(name(scope), :get)

  @doc "Bumps the value of the given counter asynchronously"
  @spec bump(pid() | slug() | ShortLink.t(), non_neg_integer()) :: :ok
  def bump(scope_or_pid, value \\ 1)

  def bump(pid, value) when is_pid(pid) do
    GenServer.cast(pid, {:bump, value})
  end

  def bump(scope, value) do
    GenServer.cast(name(scope), {:bump, value})
  end

  # SERVER API

  @impl GenServer
  def handle_continue({:hydrate_state, slug}, init_state) do
    # TODO - add non-"!" version that does something appropriate. Probably just shutdown.
    short_link = init_state.context_mod.get_short_link_by_slug!(slug)
    state = %{init_state | short_link: short_link}

    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    {:reply, state.counter + state.short_link.times_used, state}
  end

  @persist_delay 5_000

  @impl GenServer
  def handle_cast({:bump, value}, state) do
    if state.timer_ref do
      {:noreply, %{state | counter: state.counter + value}}
    else
      timer_ref = Process.send_after(self(), :persist, @persist_delay)
      {:noreply, %{state | counter: state.counter + value, timer_ref: timer_ref}}
    end
  end

  @impl GenServer
  def handle_info(:persist, state) do
    # TODO - make this async too, but I'm tired and it's late
    state =
      case state.context_mod.add_times_used_to_short_link(state.short_link, state.counter) do
        {1, [short_link]} ->
          Logger.debug(
            message: "slug times_used updated",
            slug: state.slug,
            times_used: short_link.times_used
          )

          %{state | counter: 0, short_link: short_link}

        {0, nil} ->
          Logger.error(
            message: "slug failed to update times_used",
            slug: state.slug,
            previous_times_used: state.short_link.times_used,
            counter: state.counter
          )

          state
      end

    {:noreply, %{state | timer_ref: nil}}
  end

  # ERROR LOGS

  defp log_start_error(error, slug_or_short_link, scope) do
    {reason, message} =
      case error do
        :ignore -> {:ignored, "Counter was explicitly ignored"}
        {:error, reason} -> {reason, "Could not find or start a Counter"}
      end

    Logger.warning(
      message: message,
      reason: reason,
      slug_or_short_link: slug_or_short_link,
      scope: scope
    )

    nil
  end

  def name(slug) when is_binary(slug), do: wrap_as_via(slug)
  def name({nil, slug}), do: name(slug)
  def name({ns, slug}) when is_binary(slug), do: wrap_as_via({ns, slug})
  def name(scope) when is_list(scope), do: name(Map.new(scope))
  def name(%{namespace: ns, slug: slug}), do: name({ns, slug})
  def name(%{slug: slug}), do: name(slug)

  def name(slug, scope) when is_binary(slug) do
    scope
    |> Enum.into(%{slug: slug})
    |> name()
  end

  defp wrap_as_via(key), do: {:via, Registry, {UniqueRegistry, key}}
end
