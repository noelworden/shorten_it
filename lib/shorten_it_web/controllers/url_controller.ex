defmodule ShortenItWeb.UrlController do
  use ShortenItWeb, :controller

  alias ShortenIt.Shortening
  alias ShortenIt.Shortening.Url

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    urls = Shortening.list_urls()
    render(conn, :index, urls: urls)
  end

  @spec new(Plug.Conn.t(), any) :: Plug.Conn.t()
  def new(conn, _params) do
    changeset = Shortening.change_url(%Url{})
    render(conn, :new, changeset: changeset)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
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

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    url = Shortening.get_url!(id)
    render(conn, :show, url: url)
  end

  def reroute(conn, %{"shortened_url" => shortened_url}) do
    url = Shortening.get_url_and_update_counter(shortened_url)

    if is_nil(url) do
      conn
      |> put_flash(:error, "That URL does not exist")
      |> redirect(to: ~p"/")
    else
      redirect(conn, external: url)
    end
  end
end
