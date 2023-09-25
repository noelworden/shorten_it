defmodule ShortenIt.Shortening do
  @moduledoc """
  The Shortening context.
  """

  import Ecto.Query, warn: false
  alias ShortenIt.Repo

  alias ShortenIt.Shortening.Url

  @shortcode_characters ~w[A B C D E F G H I J K L M N P Q R S T U V W X Y Z a b c d e f g h
                           i j k l m n p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 - _ ~ ! * ( )]

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

  def get_url!(id), do: Repo.get!(Url, id)

  @doc """
  Gets a single url, increments the `visited_count`, and returns the `original_url.

  Returns nil if the record does not exist
  ## Examples

      iex> get_url_and_update_counter("Cf6FG4XSDcc5")
      "http://www.example.com"

      iex> get_url!(456)
      nil

  """
  def get_url_and_update_counter(shortcode) do
    url = Repo.get_by(Url, shortened_url: shortcode)

    if is_nil(url) do
      nil
    else
      update_url(url, %{visit_count: url.visit_count + 1})
      url.original_url
    end
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
    original_url = Map.get(attrs, "original_url")

    with {:valid_original_url, true} <-
           {:valid_original_url, Regex.match?(Url.valid_original_url_regex(), original_url)},
         shortened_url = shortcode_generator(),
         {:shortened_url_exists, nil} <- {:shortened_url_exists, Repo.get_by(Url, shortened_url: shortened_url)} do
      attrs = Map.merge(%{"shortened_url" => shortened_url}, attrs)

      %Url{}
      |> Url.changeset(attrs)
      |> Repo.insert()
    else
      {:valid_original_url, false} -> {:error, :invalid_input}
      {:shortened_url_exists, %Url{}} -> create_url()
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
  Returns an `%Ecto.Changeset{}` for tracking url changes.

  ## Examples

      iex> change_url(url)
      %Ecto.Changeset{data: %Url{}}

  """
  def change_url(%Url{} = url, attrs \\ %{}) do
    Url.changeset(url, attrs)
  end

  defp shortcode_generator do
    Enum.reduce(1..11, "", fn _, acc ->
      character = Enum.random(@shortcode_characters)
      acc <> to_string(character)
    end)
  end
end
