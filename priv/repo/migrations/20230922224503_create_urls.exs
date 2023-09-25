defmodule ShortenIt.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :original_url, :text, null: false
      add :shortened_url, :string, null: false
      add :visit_count, :bigint, null: false, default: 0

      timestamps()
    end

    create index(:urls, [:shortened_url])
    create unique_index(:urls, [:shortened_url], name: :urls_shortened_unique_url_index)
  end
end
