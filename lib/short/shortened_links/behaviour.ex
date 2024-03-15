defmodule Short.ShortenedLinks.Behaviour do
  @moduledoc """
  The behaviour for a `Short.ShortenedLinks`. Created to allow use of mocked,
  or alternate implementations, most often when testing.

  See `Short.ShortenedLinks` for more information.
  """

  alias Short.ShortenedLinks.ShortLink
  alias Short.ShortenedLinks.Slug

  @type result_tuple() :: {:ok, ShortLink.t()} | {:error, Ecto.Changeset.t(ShortLink.t())}
  @type attrs() :: map()

  @callback list_short_links() :: [ShortLink.t()]
  @callback get_short_link!(id :: pos_integer()) :: ShortLink.t() | no_return()
  @callback get_short_link_by_slug!(slug :: Slug.t()) :: ShortLink.t() | no_return()
  @callback create_short_link(attrs()) :: result_tuple()
  @callback update_short_link(ShortLink.t(), attrs()) :: result_tuple()
  @callback add_times_used_to_short_link(ShortLink.t(), non_neg_integer()) ::
              {non_neg_integer(), [ShortLink.t()]}
  @callback delete_short_link(ShortLink.t()) :: result_tuple()
  @callback change_short_link(ShortLink.t(), attrs()) :: Ecto.Changeset.t(ShortLink.t())
end
