defmodule Short.Counters.Supervisor do
  @moduledoc """
  The top-level Supervisor responsible for starting up the counter hydration worker and supervising the
  `CounterSupervisor`.

  This module does not supervise any `Counter` process directly.
  See `Short.Counters.CounterSupervisor` for that.

  As with all of the supervision for  `Short.Counters`, it uses a `name/1` function that
  calls to `name/0` by default, but can be overridden with a custom `:namespace` key in a map
  passed as part of the initial args, and will be passed to any subsequent children.
  """

  use Supervisor

  alias Short.Counters.UniqueRegistry

  def start_link(options \\ []) do
    sup_opts = [name: name(Map.new(options))]
    opts = Keyword.drop(options, [:name])

    if config()[:on_startup] or sup_opts[:name] != name() do
      Supervisor.start_link(__MODULE__, opts, sup_opts)
    else
      :ignore
    end
  end

  def init(options) do
    children = [
      {Short.Counters.CounterSupervisor, options},
      {Short.Counters.CounterHydrater, options}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  # Makes multi-tenancy and testing easier
  def name, do: {:via, Registry, {UniqueRegistry, __MODULE__}}

  def name(scope) when is_list(scope), do: name(Map.new(scope))
  def name(%{namespace: nil}), do: name()
  def name(%{namespace: ns}), do: {:via, Registry, {UniqueRegistry, {ns, __MODULE__}}}
  def name(_), do: name()

  def config do
    Application.get_env(:short, __MODULE__, on_startup: true)
  end
end
