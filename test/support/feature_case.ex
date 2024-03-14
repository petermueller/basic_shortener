defmodule ShortWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by tests that require setting up
  a connection to test feature tests.

  Such tests rely on `PhoenixTest` and also import other functionality to
  make it easier to build common data structures and interact with pages.

  Finally, if the test case interacts with the database, we enable the SQL
  sandbox, so changes done to the database are reverted at the end of every
  test. If you are using PostgreSQL, you can even run database tests
  asynchronously by setting `use ShortWeb.FeatureCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use ShortWeb, :verified_routes

      import ShortWeb.FeatureCase

      import PhoenixTest
    end
  end

  setup tags do
    Short.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
