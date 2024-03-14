defmodule Short.ShortenedLinksTest do
  use Short.DataCase

  alias Short.ShortenedLinks

  describe "short_link" do
    alias Short.ShortenedLinks.ShortLink

    import Short.ShortenedLinksFixtures

    @invalid_attrs %{status: nil, slug: nil, long_url: nil, times_used: 42}

    test "list_short_link/0 returns all short_link" do
      short_link = short_link_fixture()
      assert ShortenedLinks.list_short_link() == [short_link]
    end

    test "get_short_link!/1 returns the short_link with given id" do
      short_link = short_link_fixture()
      assert ShortenedLinks.get_short_link!(short_link.id) == short_link
    end

    test "create_short_link/1 with valid data creates a short_link" do
      valid_attrs = %{status: :unpublished, slug: "someSlug", long_url: "https://example.com"}

      assert {:ok, %ShortLink{} = short_link} = ShortenedLinks.create_short_link(valid_attrs)
      assert short_link.status == :unpublished
      assert short_link.slug == "someSlug"
      assert short_link.long_url == "https://example.com"
      assert short_link.times_used == 0
    end

    test "create_short_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ShortenedLinks.create_short_link(@invalid_attrs)
    end

    test "update_short_link/2 with valid data updates the short_link" do
      short_link = short_link_fixture()

      update_attrs = %{
        status: :published,
        slug: "someUpdatedSlug",
        long_url: "https://example.com/updated"
      }

      assert {:ok, %ShortLink{} = short_link} =
               ShortenedLinks.update_short_link(short_link, update_attrs)

      assert short_link.status == :published
      assert short_link.slug == "someUpdatedSlug"
      assert short_link.long_url == "https://example.com/updated"
      assert short_link.times_used == 0
    end

    test "update_short_link/2 with invalid data returns error changeset" do
      short_link = short_link_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ShortenedLinks.update_short_link(short_link, @invalid_attrs)

      assert short_link == ShortenedLinks.get_short_link!(short_link.id)
    end

    test "delete_short_link/1 deletes the short_link" do
      short_link = short_link_fixture()
      assert {:ok, %ShortLink{}} = ShortenedLinks.delete_short_link(short_link)
      assert_raise Ecto.NoResultsError, fn -> ShortenedLinks.get_short_link!(short_link.id) end
    end

    test "change_short_link/1 returns a short_link changeset" do
      short_link = short_link_fixture()
      assert %Ecto.Changeset{} = ShortenedLinks.change_short_link(short_link)
    end
  end
end
