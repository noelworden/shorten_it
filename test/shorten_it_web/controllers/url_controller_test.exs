defmodule ShortenItWeb.UrlControllerTest do
  use ShortenItWeb.ConnCase

  alias ShortenIt.Shortening

  @create_attrs %{original_url: "https://wwww.example.com"}
  @invalid_attrs %{original_url: "bad url"}

  describe "index" do
    test "lists all urls", %{conn: conn} do
      conn = get(conn, ~p"/stats")
      assert html_response(conn, 200) =~ "Listing Urls"
    end
  end

  describe "new url" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Original URL"
    end
  end

  describe "create url" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/urls", url: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/urls/#{id}"

      shortened_url = get_shortened_url(id)

      conn = get(conn, ~p"/urls/#{id}")
      assert html_response(conn, 200) =~ shortened_url
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/urls", url: @invalid_attrs)
      assert html_response(conn, 200) =~ "Original URL"
    end
  end

  defp get_shortened_url(id) do
    url = Shortening.get_url!(id)

    url.shortened_url
  end
end
