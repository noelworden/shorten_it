defmodule ShortenItWeb.ExportControllerTest do
  use ShortenItWeb.ConnCase

  alias ShortenIt.Shortening

  describe "create/2" do
    test "streams data and builds a CSV" do
      {:ok, url01} = Shortening.create_url(%{"original_url" => "http://www.example01.com"})
      {:ok, url02} = Shortening.create_url(%{"original_url" => "http://www.example02.com"})
      {:ok, url03} = Shortening.create_url(%{"original_url" => "http://www.example03.com"})

      response = HTTPoison.get!("http://localhost:4002/export")

      assert response.status_code == 200
      assert get_header_info(response.headers, "transfer-encoding") == "chunked"
      assert get_header_info(response.headers, "content-type") == "text/csv; charset=utf-8"

      assert get_header_info(response.headers, "content-disposition") ==
               "attachment; filename=\"url_shortener_export.csv\""

      expected_csv_content =
        "original url,shortened url,visit count\r\n" <>
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

      assert response.body == expected_csv_content
    end
  end

  test "builds a CSV with only headers if there is no data" do
    response = HTTPoison.get!("http://localhost:4002/export")

    assert response.status_code == 200
    assert get_header_info(response.headers, "transfer-encoding") == "chunked"
    assert get_header_info(response.headers, "content-type") == "text/csv; charset=utf-8"

    assert get_header_info(response.headers, "content-disposition") ==
             "attachment; filename=\"url_shortener_export.csv\""

    assert response.body == "original url,shortened url,visit count\r\n"
  end

  defp get_header_info(headers, key) do
    {_key, value} = List.keyfind(headers, key, 0)

    value
  end
end
