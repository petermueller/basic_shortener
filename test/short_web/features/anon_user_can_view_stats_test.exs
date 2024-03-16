defmodule ShortWeb.Features.AnonUserCanViewStatsTest do
  use ShortWeb.FeatureCase, async: true

  test "anonymous users can download a stats CSV", %{conn: conn} do
    session =
      conn
      |> visit(~p"/stats")
      |> assert_has("#export_csv", "Export CSV")

    %{conn: conn} = click_link(session, "Export CSV")

    assert Phoenix.ConnTest.response(conn, 200)
  end
end
