defmodule ShortenIt.Shortening do
  @moduledoc """
  The Shortening context.
  """

  import Ecto.Query, warn: false
  alias ShortenIt.Repo

  alias ShortenIt.Shortening.Url

  @shortcode_characters ~w[A B C D E F G H I J K L M N P Q R S T U V W X Y Z a b c d e f g h
                           i j k l m n p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 - _ ~ ! * ( )]

  @spec list_urls :: map
  @doc """
  Returns the list of urls.

  ## Examples

      iex> list_urls()
      [%Url{}, ...]

  """
  def list_urls do
    Repo.all(from(u in Url, order_by: [desc: u.visit_count]))
  end

  @spec get_url!(Integer.t()) :: Url.t()
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

  @spec get_url_and_update_counter(String.t()) :: nil | String.t()
  @doc """
  Gets a single url, increments the `visited_count`, and returns the `original_url`.

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

  @spec create_url(map, (() -> any)) :: {:ok, Url.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Creates a url.

  ## Examples

      iex> create_url(%{field: value})
      {:ok, %Url{}}

      iex> create_url(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_url(attrs \\ %{}, shortcode_generator \\ &shortcode_generator/0) do
    shortened_url = shortcode_generator.()

    attrs = Map.put(attrs, "shortened_url", shortened_url)

    result =
      %Url{}
      |> Url.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, result} ->
        {:ok, result}

      {:error, %Ecto.Changeset{errors: [shortened_url: _]}} ->
        create_url(attrs, shortcode_generator)

      {:error, %Ecto.Changeset{errors: [original_url: _]} = changeset} ->
        {:error, changeset}
    end
  end

  @spec update_url(map, map) :: {:ok, Url.t()} | {:error, Ecto.Changeset.t()}
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

  @spec change_url(map, map) :: Ecto.Changeset.t()
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
