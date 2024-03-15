defmodule Short.Counters.CounterHydrater do
  @moduledoc """
  A module for finding/starting `Counter` processes,
  and making sure they're properly supervised, both at start-up and ad-hoc.


  As with all of the supervision for  `Short.Counters`, it uses a `name/1` function that
  calls to `name/0` by default, but can be overridden with a custom `:namespace` key in a map
  passed as part of the initial args, and will be passed to any subsequent children this module is
  used to start.
  """

  @behaviour GenServer

  alias Short.Counters.CounterSupervisor
  alias Short.Counters.UniqueRegistry

  # INITIALIZATION

  def child_spec(overrides) do
    # Allow overrides
    opts = Enum.into(overrides, %{context_mod: Short.ShortenedLinks})

    %{id: __MODULE__, start: {__MODULE__, :start_link, [opts]}}
  end

  @spec start_link(init_arg :: map()) :: GenServer.on_start()
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: name(init_arg))
  end

  @impl GenServer
  def init(init_arg) do
    init_state = Map.put(init_arg, :hydrated_children, [])

    {:ok, init_state, {:continue, :hydrate_and_maybe_start_all}}
  end

  # CLIENT API

  def list_counters_hydrated, do: list_counters_hydrated([])

  def list_counters_hydrated(hydrater_pid) when is_pid(hydrater_pid) do
    GenServer.call(hydrater_pid, :list_hydrated)
  end

  def list_counters_hydrated(scope) do
    GenServer.call(name(scope), :list_hydrated)
  end

  # SERVER API

  @impl GenServer
  def handle_continue(:hydrate_and_maybe_start_all, state) do
    stored_child_states = state.context_mod.list_short_links()

    {:noreply, state, {:continue, {:start_children, stored_child_states}}}
  end

  def handle_continue({:start_children, [child_state | remaining_states]}, state) do
    slug = Map.fetch!(child_state, :slug)

    sup_name = CounterSupervisor.name(state)

    # Don't store the child pid as "hydrated" as it may get restarted, and wasn't hydrated at `init`
    {:ok, _child_pid} =
      CounterSupervisor.start_child(sup_name, {child_state, [context_mod: state.context_mod]})

    state = update_in(state.hydrated_children, &[slug | &1])
    {:noreply, state, {:continue, {:start_children, remaining_states}}}
  end

  def handle_continue({:start_children, []}, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:list_hydrated, _from, state) do
    {:reply, state.hydrated_children, state}
  end

  # ClIENT API

  def name, do: {:via, Registry, {UniqueRegistry, __MODULE__}}

  def name(scope) when is_list(scope), do: name(Map.new(scope))
  def name(%{namespace: nil}), do: name()
  def name(%{namespace: ns}), do: {:via, Registry, {UniqueRegistry, {ns, __MODULE__}}}
  def name(_), do: name()
end
