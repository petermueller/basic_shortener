defmodule ShortWeb.AnonUserCanShortenLinkTest do
  use ShortWeb.FeatureCase, async: true

  test "anonymous users can shorten links", %{conn: conn} do

    session =
      conn
      |> visit(~p"/")
      |> submit_form("#short-link-form", short_link: %{long_url: "https://example.com"})
      |> assert_has(".short-link", "Times used")

    %{conn: conn} = click_link(session, "Test")

    assert Phoenix.ConnTest.redirected_to(conn) =~ "https://example.com"
  end
end
