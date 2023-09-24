defmodule ShortenIt.Shortening do
  @moduledoc """
  The Shortening context.
  """

  import Ecto.Query, warn: false
  alias ShortenIt.Repo

  alias ShortenIt.Shortening.Url

  @shortcode_characters ~w[A B C D E F G H I J K L M N P Q R S T U V W X Y Z a b c d e f g h i j k l m n p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 - _ ~ ! * ( ) ']

  @doc """
  Returns the list of urls.

  ## Examples

      iex> list_urls()
      [%Url{}, ...]

  """
  def list_urls do
    Repo.all(from(u in Url, order_by: [desc: u.visit_count]))
  end

  @doc """
  Gets a single url.

  Raises `Ecto.NoResultsError` if the Url does not exist.

  ## Examples

      iex> get_url!(123)
      %Url{}

      iex> get_url!(456)
      ** (Ecto.NoResultsError)

  """
  def get_url_and_update_counter(shortcode) do
    url = Repo.get_by(Url, shortened_url: shortcode)

    update_url(url, %{visit_count: url.visit_count + 1})

    url.original_url
  end

  @doc """
  Creates a url.

  ## Examples

      iex> create_url(%{field: value})
      {:ok, %Url{}}

      iex> create_url(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_url(attrs \\ %{}) do
    shortened_url = shortcode_generator()

    existing = Repo.get_by(Url, shortened_url: shortened_url)

    if existing do
      create_url()
    else
      attrs = Map.merge(%{shortened_url: shortened_url}, attrs)

      %Url{}
      |> Url.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Updates a url.

  ## Examples

      iex> update_url(url, %{field: new_value})
      {:ok, %Url{}}

      iex> update_url(url, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_url(%Url{} = url, attrs) do
    url
    |> Url.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a url.

  ## Examples

      iex> delete_url(url)
      {:ok, %Url{}}

      iex> delete_url(url)
      {:error, %Ecto.Changeset{}}

  """
  def delete_url(%Url{} = url) do
    Repo.delete(url)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking url changes.

  ## Examples

      iex> change_url(url)
      %Ecto.Changeset{data: %Url{}}

  """
  def change_url(%Url{} = url, attrs \\ %{}) do
    Url.changeset(url, attrs)
  end

  def shortcode_generator do
    Enum.reduce(1..11, "", fn _, acc ->
      character = Enum.random(@shortcode_characters)
      acc <> to_string(character)
    end)
  end
end
