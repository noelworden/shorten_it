defmodule ShortenItWeb.ExportControllerTest do
  use ShortenItWeb.ConnCase

  alias ShortenIt.Shortening

  @tag timeout: :infinity
  test "create/2 returns csv data", %{conn: conn} do
    {:ok, url01} = Shortening.create_url(%{"original_url" => "http://www.example.com"})
    {:ok, url02} = Shortening.create_url(%{"original_url" => "http://www.example.com"})
    {:ok, url03} = Shortening.create_url(%{"original_url" => "http://www.example.com"})

    conn = post(conn, ~p"/export")

    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["text/csv; charset=utf-8"]
    assert get_resp_header(conn, "content-disposition") == ["attachment; filename=\"url_shortener_export.csv\""]

    expected_csv_content =
      "original_url,shortened_url,visit_count\r\n" <>
        url01.original_url <>
        "," <>
        url01.shortened_url <>
        "," <>
        to_string(url01.visit_count) <>
        "\r\n" <>
        url02.original_url <>
        "," <>
        url02.shortened_url <>
        "," <>
        to_string(url02.visit_count) <>
        "\r\n" <> url03.original_url <> "," <> url03.shortened_url <> "," <> to_string(url03.visit_count) <> "\r\n"

    assert conn.resp_body == expected_csv_content
  end
end
