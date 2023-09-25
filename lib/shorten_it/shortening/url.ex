defmodule ShortenIt.Shortening.Url do
  @moduledoc """
  Schema and validations for the urls table
  """
  use Ecto.Schema
  import Ecto.Changeset

  @valid_original_url_regex ~r/https?:\/\//

  schema "urls" do
    field :original_url, :string
    field :shortened_url, :string
    field :visit_count, :integer, default: 0

    timestamps()
  end

  def valid_original_url_regex, do: @valid_original_url_regex
  @doc false
  def changeset(url, attrs) do
    url
    |> cast(attrs, [:original_url, :shortened_url, :visit_count])
    |> validate_required([:original_url, :shortened_url])
    |> unique_constraint(:shortened_url)
    |> validate_format(:original_url, @valid_original_url_regex,
      message: "The url needs to begin with 'http://' or 'https://'"
    )
  end
end
