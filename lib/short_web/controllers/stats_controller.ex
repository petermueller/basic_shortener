defmodule ShortWeb.StatsController do
  use ShortWeb, :controller

  alias Short.ShortenedLinks

  def index(conn, _params) do
    short_links = ShortenedLinks.list_short_links(order_by: [desc: :times_used])
    render(conn, :index, short_link_collection: short_links)
  end

  def csv(conn, _params) do
    short_links = ShortenedLinks.list_short_links(order_by: [desc: :times_used])

    stream =
      short_links
      |> Stream.map(fn short_link ->
        %{
          short_url: unverified_url(conn, short_link.slug),
          long_url: URI.parse(short_link.long_url)
        }
      end)
      |> CSV.encode(headers: [:short_url, :long_url], escape_formulas: true)

    conn =
      conn
      |> put_resp_content_type("text/csv")
      # This is because Plug does not do content-disposition properly
      # and there's no accepted standards-compliant implementation in Elixir
      # See my thread on the forums:
      # https://elixirforum.com/t/library-for-parsing-and-building-rfc-compliant-content-disposition-headers/55708
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"stats.csv\"; filename*=UTF-8''stats.csv"
      )
      |> send_chunked(200)

    Enum.reduce_while(stream, conn, fn chunk, conn ->
      case Plug.Conn.chunk(conn, chunk) do
        {:ok, conn} -> {:cont, conn}
        {:error, :closed} -> {:halt, conn}
      end
    end)
  end
end
