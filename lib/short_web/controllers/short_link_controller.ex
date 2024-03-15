defmodule ShortWeb.ShortLinkController do
  use ShortWeb, :controller

  alias Short.ShortenedLinks
  alias Short.ShortenedLinks.ShortLink

  def redirect_slug(conn, %{"slug" => slug}) do
    short_link = ShortenedLinks.get_short_link_by_slug!(slug)
    Short.Counters.Counter.bump(short_link)
    redirect(conn, external: short_link.long_url)
  end

  def index(conn, _params) do
    short_link = ShortenedLinks.list_short_links()
    render(conn, :index, short_link_collection: short_link)
  end

  def new(conn, _params) do
    changeset = ShortenedLinks.change_short_link(%ShortLink{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"short_link" => short_link_params}) do
    case ShortenedLinks.create_short_link(short_link_params) do
      {:ok, short_link} ->
        Short.Counters.Counter.find_or_start(short_link)

        conn
        |> put_flash(:info, "Short link created successfully.")
        |> redirect(to: ~p"/short_link/#{short_link}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    short_link = ShortenedLinks.get_short_link!(id)
    render(conn, :show, short_link: short_link)
  end

  def edit(conn, %{"id" => id}) do
    short_link = ShortenedLinks.get_short_link!(id)
    changeset = ShortenedLinks.change_short_link(short_link)
    render(conn, :edit, short_link: short_link, changeset: changeset)
  end

  def update(conn, %{"id" => id, "short_link" => short_link_params}) do
    short_link = ShortenedLinks.get_short_link!(id)

    case ShortenedLinks.update_short_link(short_link, short_link_params) do
      {:ok, short_link} ->
        conn
        |> put_flash(:info, "Short link updated successfully.")
        |> redirect(to: ~p"/short_link/#{short_link}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, short_link: short_link, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    short_link = ShortenedLinks.get_short_link!(id)
    {:ok, _short_link} = ShortenedLinks.delete_short_link(short_link)

    conn
    |> put_flash(:info, "Short link deleted successfully.")
    |> redirect(to: ~p"/short_link")
  end
end
