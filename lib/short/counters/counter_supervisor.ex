defmodule Short.Counters.CounterSupervisor do
  @moduledoc """
  This module is used to start a `DynamicSupervisor` for `Counter` processes, with some sensible
  defaults, and `:extra_arguments` passed to the child processes.

  As with all of the supervision for  `Short.Counters`, it uses a `name/1` function that
  calls to `name/0` by default, but can be overridden with a custom `:namespace` key in a map
  passed as part of the initial args, and will be passed to any subsequent children.
  """

  alias Short.Counters.UniqueRegistry

  @doc """
  Returns a `t:Supervisor.child_spec/0` for this module, defaulting the name, if not provided.
  """
  def child_spec(overrides) do
    # Allow overrides
    opts = Keyword.merge([name: name(overrides)], Enum.to_list(overrides))

    # use DynamicSupervisor's name/id checking
    opts
    |> DynamicSupervisor.child_spec()
    # override the `:start` to use this module instead of DynamicSupervisor
    |> Supervisor.child_spec(start: {__MODULE__, :start_link, [opts]})
  end

  def start_link(init_arg) do
    sup_opts =
      case init_arg[:namespace] do
        nil -> []
        ns -> [extra_arguments: [[namespace: ns]]]
      end

    options = [strategy: :one_for_one] ++ init_arg ++ sup_opts
    DynamicSupervisor.start_link(options)
  end

  def start_child(init_opts), do: start_child(name(), init_opts)

  def start_child(supervisor, init_opts) do
    DynamicSupervisor.start_child(supervisor, {Short.Counters.Counter, init_opts})
  end

  def which_children, do: which_children([])

  def which_children(pid) when is_pid(pid), do: DynamicSupervisor.which_children(pid)
  def which_children(scope), do: DynamicSupervisor.which_children(name(scope))

  # Makes multi-tenancy and testing easier
  def name, do: {:via, Registry, {UniqueRegistry, __MODULE__}}

  def name(scope) when is_list(scope), do: name(Map.new(scope))
  def name(%{namespace: nil}), do: name()
  def name(%{namespace: ns}), do: {:via, Registry, {UniqueRegistry, {ns, __MODULE__}}}
  def name(_), do: name()
end
