defmodule ShortenItWeb.ExportController do
  use ShortenItWeb, :controller

  import Ecto.Query
  alias ShortenIt.Repo
  alias ShortenIt.Shortening.Url

  def create(conn, _params) do
    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"url_shortener_export.csv\"")
      |> send_chunked(200)

    chunk(conn, NimbleCSV.RFC4180.dump_to_iodata([["original url", "shortened url", "visit count"]]))

    query = from(u in Url, select: {u.original_url, u.shortened_url, u.visit_count})

    Repo.transaction(fn ->
      for {original_url, shortened_url, visit_count} <- Repo.stream(query) do
        chunk(conn, NimbleCSV.RFC4180.dump_to_iodata([[original_url, shortened_url, visit_count]]))
      end
    end)

    conn
  end
end
