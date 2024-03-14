defmodule ShortWeb.AnonUserCanShortenLinkTest do
  use ShortWeb.FeatureCase, async: true

  test "anonymous users can shorten links", %{conn: conn} do
    conn
    |> visit(~p"/")
    |> submit_form("#short-link-form", short_link: %{long_url: "https://example.com"})
  end
end
