defmodule ShortenIt.Shortening.Url do
  @moduledoc """
  Schema and validations for the urls table
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "urls" do
    field :original_url, :string
    field :shortened_url, :string
    field :visit_count, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(url, attrs) do
    url
    |> cast(attrs, [:original_url, :shortened_url, :visit_count])
    |> validate_required([:original_url, :shortened_url])
    |> unique_constraint(:shortened_url)
  end
end
