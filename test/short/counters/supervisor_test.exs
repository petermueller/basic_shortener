defmodule Short.Counters.SupervisorTest do
  @moduledoc false

  use Short.DataCase, async: false

  import Mox
  import Short.ShortenedLinksFixtures

  alias Short.Counters.Counter
  alias Short.Counters.CounterHydrater
  alias Short.Counters.CounterSupervisor
  alias Short.Counters.Supervisor, as: TopSupervisor
  alias Short.Counters.UniqueRegistry

  setup meta do
    stub_with(LinksMock, Short.ShortenedLinks)
    set_mox_from_context(meta)

    expect(LinksMock, :list_short_links, &Short.ShortenedLinks.list_short_links/0)

    args = [namespace: meta.test]
    allow(LinksMock, self(), CounterHydrater.name(args))
    allow(LinksMock, self(), Counter.name("someSlug", args))
    :ok
  end

  describe "start_link/1" do
    test "starts w/ a registry :via tuple that can be namespaced", meta do
      args = [context_mod: LinksMock, namespace: meta.test]
      pid = start_supervised!({TopSupervisor, args})
      [{^pid, _}] = Registry.lookup(UniqueRegistry, {meta.test, TopSupervisor})

      Supervisor.which_children(pid)
    end
  end

  describe "at startup" do
    test "starts all the processes and hydrates Trackers", meta do
      # Use a namespace in testing so it won't conflict with application.ex
      args = [context_mod: LinksMock, namespace: meta.test]

      slug = "someSlug"
      _short_link = short_link_fixture(slug: slug)

      main_sup_pid = start_supervised!({Short.Counters.Supervisor, args})

      assert [
               {_, hydrater_pid, _, _},
               {_, top_sup_pid, _, _}
             ] = Supervisor.which_children(main_sup_pid)

      # Check that it is registered w/ the provided namespace
      assert [{^hydrater_pid, _}] = Registry.lookup(UniqueRegistry, {meta.test, CounterHydrater})
      assert [{^top_sup_pid, _}] = Registry.lookup(UniqueRegistry, {meta.test, CounterSupervisor})

      # Check it starts the trackers
      # It also implicitly waits on the hydrater process to be "ready"/idle
      assert [^slug] = CounterHydrater.list_counters_hydrated(namespace: meta.test)
    end
  end
end
