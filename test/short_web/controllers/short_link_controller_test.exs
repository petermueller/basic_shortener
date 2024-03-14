defmodule ShortWeb.ShortLinkControllerTest do
  use ShortWeb.ConnCase

  import Short.ShortenedLinksFixtures

  @create_attrs %{status: :unpublished, slug: "some slug", long_url: "some long_url", times_used: 42}
  @update_attrs %{status: :published, slug: "some updated slug", long_url: "some updated long_url", times_used: 43}
  @invalid_attrs %{status: nil, slug: nil, long_url: nil, times_used: nil}

  describe "index" do
    test "lists all short_link", %{conn: conn} do
      conn = get(conn, ~p"/short_link")
      assert html_response(conn, 200) =~ "Listing Short link"
    end
  end

  describe "new short_link" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/short_link/new")
      assert html_response(conn, 200) =~ "New Short link"
    end
  end

  describe "create short_link" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/short_link", short_link: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/short_link/#{id}"

      conn = get(conn, ~p"/short_link/#{id}")
      assert html_response(conn, 200) =~ "Short link #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/short_link", short_link: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Short link"
    end
  end

  describe "edit short_link" do
    setup [:create_short_link]

    test "renders form for editing chosen short_link", %{conn: conn, short_link: short_link} do
      conn = get(conn, ~p"/short_link/#{short_link}/edit")
      assert html_response(conn, 200) =~ "Edit Short link"
    end
  end

  describe "update short_link" do
    setup [:create_short_link]

    test "redirects when data is valid", %{conn: conn, short_link: short_link} do
      conn = put(conn, ~p"/short_link/#{short_link}", short_link: @update_attrs)
      assert redirected_to(conn) == ~p"/short_link/#{short_link}"

      conn = get(conn, ~p"/short_link/#{short_link}")
      assert html_response(conn, 200) =~ "some updated slug"
    end

    test "renders errors when data is invalid", %{conn: conn, short_link: short_link} do
      conn = put(conn, ~p"/short_link/#{short_link}", short_link: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Short link"
    end
  end

  describe "delete short_link" do
    setup [:create_short_link]

    test "deletes chosen short_link", %{conn: conn, short_link: short_link} do
      conn = delete(conn, ~p"/short_link/#{short_link}")
      assert redirected_to(conn) == ~p"/short_link"

      assert_error_sent 404, fn ->
        get(conn, ~p"/short_link/#{short_link}")
      end
    end
  end

  defp create_short_link(_) do
    short_link = short_link_fixture()
    %{short_link: short_link}
  end
end
