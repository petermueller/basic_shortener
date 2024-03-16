defmodule Short.ShortenedLinks do
  @moduledoc """
  The ShortenedLinks context.
  """

  @behaviour Short.ShortenedLinks.Behaviour

  import Ecto.Query, warn: false

  alias Short.Repo
  alias Short.ShortenedLinks.ShortLink

  @doc """
  Returns the list of short_link.

  ## Examples

      iex> list_short_links()
      [%ShortLink{}, ...]

      iex> list_short_links(order_by: [desc: :times_used])
      [%ShortLink{times_used: 3}, %ShortLink{times_used: 2}, ...]

  """
  @impl Short.ShortenedLinks.Behaviour
  def list_short_links(opts \\ []) do
    base_query = from(s in ShortLink)

    opts
    |> Enum.reduce(base_query, fn
      {:order_by, kw_list}, query -> order_by(query, ^kw_list)
      _, query -> query
    end)
    |> Repo.all()
  end

  @doc """
  Gets a single short_link.

  Raises `Ecto.NoResultsError` if the Short link does not exist.

  ## Examples

      iex> get_short_link!(123)
      %ShortLink{}

      iex> get_short_link!(456)
      ** (Ecto.NoResultsError)

  """
  @impl Short.ShortenedLinks.Behaviour
  def get_short_link!(id), do: Repo.get!(ShortLink, id)

  @impl Short.ShortenedLinks.Behaviour
  def get_short_link_by_slug!(slug), do: Repo.get_by!(ShortLink, slug: slug)

  @doc """
  Creates a short_link.

  ## Examples

      iex> create_short_link(%{field: value})
      {:ok, %ShortLink{}}

      iex> create_short_link(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl Short.ShortenedLinks.Behaviour
  def create_short_link(attrs \\ %{}) do
    %ShortLink{}
    |> ShortLink.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a short_link.

  ## Examples

      iex> update_short_link(short_link, %{field: new_value})
      {:ok, %ShortLink{}}

      iex> update_short_link(short_link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl Short.ShortenedLinks.Behaviour
  def update_short_link(%ShortLink{} = short_link, attrs) do
    short_link
    |> ShortLink.changeset(attrs)
    |> Repo.update()
  end

  @impl Short.ShortenedLinks.Behaviour
  def add_times_used_to_short_link(%ShortLink{} = short_link, incr) do
    Repo.update_all(
      from(s in ShortLink,
        where: s.id == ^short_link.id,
        update: [inc: [times_used: ^incr]],
        select: s
      ),
      set: [updated_at: DateTime.utc_now()]
    )
  end

  @doc """
  Deletes a short_link.

  ## Examples

      iex> delete_short_link(short_link)
      {:ok, %ShortLink{}}

      iex> delete_short_link(short_link)
      {:error, %Ecto.Changeset{}}

  """
  @impl Short.ShortenedLinks.Behaviour
  def delete_short_link(%ShortLink{} = short_link) do
    Repo.delete(short_link)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking short_link changes.

  ## Examples

      iex> change_short_link(short_link)
      %Ecto.Changeset{data: %ShortLink{}}

  """
  @impl Short.ShortenedLinks.Behaviour
  def change_short_link(%ShortLink{} = short_link, attrs \\ %{}) do
    ShortLink.changeset(short_link, attrs)
  end
end
