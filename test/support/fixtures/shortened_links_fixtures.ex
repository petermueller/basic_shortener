defmodule Short.ShortenedLinksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Short.ShortenedLinks` context.
  """

  @doc """
  Generate a unique short_link slug.
  """
  def unique_short_link_slug, do: "someSlug#{System.unique_integer([:positive])}"

  def long_url, do: Faker.Internet.url()

  @doc """
  Generate a short_link.
  """
  def short_link_fixture(attrs \\ %{}) do
    {:ok, short_link} =
      attrs
      |> Enum.into(%{long_url: long_url()})
      |> Short.ShortenedLinks.create_short_link()

    short_link
  end
end
