defmodule ShortWeb.StatsControllerTest do
  use ShortWeb.ConnCase

  import Short.ShortenedLinksFixtures

  setup do
    example_com_stream =
      ["https://example.com/"]
      |> Stream.cycle()
      |> Stream.with_index(1)
      |> Stream.map(fn {url, idx} ->
        {url <> to_string(idx), idx}
      end)

    short_links =
      for {url, idx} <- Enum.take(example_com_stream, 10) do
        [long_url: url]
        |> short_link_fixture()
        |> Short.ShortenedLinks.add_times_used_to_short_link(idx)
      end

    [short_links: short_links]
  end

  describe "index" do
    test "lists stats for all short links", %{conn: conn} do
      conn = get(conn, ~p"/stats")
      assert body = html_response(conn, 200)
      assert body =~ "Stats"

      html = Floki.parse_document!(body)

      links = Floki.attribute(html, "a.long_url", "href")

      times_used =
        html
        |> Floki.find(".times_used")
        |> Enum.map(&Floki.text/1)

      assert Enum.zip(links, times_used) == [
               {"https://example.com/10", "10"},
               {"https://example.com/9", "9"},
               {"https://example.com/8", "8"},
               {"https://example.com/7", "7"},
               {"https://example.com/6", "6"},
               {"https://example.com/5", "5"},
               {"https://example.com/4", "4"},
               {"https://example.com/3", "3"},
               {"https://example.com/2", "2"},
               {"https://example.com/1", "1"}
             ]
    end
  end

  describe "csv" do
    test "downloads a CSV of the stats", %{conn: conn} do
      conn = get(conn, ~p"/stats/csv")

      assert response(conn, 200)
    end
  end
end
