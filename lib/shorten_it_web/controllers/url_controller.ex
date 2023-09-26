defmodule ShortenItWeb.UrlController do
  use ShortenItWeb, :controller

  alias ShortenIt.Shortening
  alias ShortenIt.Shortening.Url

  def index(conn, _params) do
    urls = Shortening.list_urls()
    render(conn, :index, urls: urls)
  end

  def new(conn, _params) do
    changeset = Shortening.change_url(%Url{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"url" => url_params}) do
    case Shortening.create_url(url_params) do
      {:ok, url} ->
        conn
        |> put_flash(:info, "Url created successfully.")
        |> redirect(to: ~p"/urls/#{url}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    url = Shortening.get_url!(id)
    render(conn, :show, url: url)
  end

  def reroute(conn, %{"shortened_url" => shortened_url}) do
    url = Shortening.get_url_and_update_counter(shortened_url)

    if is_nil(url) do
      conn
      |> put_flash(:error, "That URL does not exist")
      |> redirect(to: ~p"/urls")
    else
      redirect(conn, external: url)
    end
  end
end
