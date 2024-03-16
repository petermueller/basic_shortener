defmodule ShortWeb.StatsController do
  use ShortWeb, :controller

  alias Short.ShortenedLinks

  def index(conn, _params) do
    short_link = ShortenedLinks.list_short_links(order_by: [desc: :times_used])
    render(conn, :index, short_link_collection: short_link)
  end
end
