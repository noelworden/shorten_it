defmodule ShortenItWeb.ExportController do
  use ShortenItWeb, :controller

  import Ecto.Query
  alias ShortenIt.Repo
  alias ShortenIt.Shortening.Url

  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, _params) do
    fields = [:original_url, :shortened_url, :visit_count]

    query = from(u in Url, select: u)

    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"url_shortener_export.csv\"")
      |> put_root_layout(false)
      |> send_chunked(200)

    {:ok, transaction_result} =
      Repo.transaction(fn ->
        headers = Enum.join(fields, ",") <> "\r\n"

        csv_rows =
          Repo.stream(query)
          |> Stream.map(&Map.from_struct/1)
          |> Stream.map(&Map.take(&1, fields))
          |> Enum.reduce(headers, fn row, acc ->
            csv_row = CSV.encode([row], headers: true) |> Enum.to_list() |> List.delete_at(0) |> to_string()
            acc <> csv_row
          end)

        Plug.Conn.chunk(conn, csv_rows)
      end)

    case transaction_result do
      {:ok, conn} ->
        conn

      {:error, _error} ->
        %{conn | resp_body: "There was a problem building the CSV, please try again"}
    end
  end
end
