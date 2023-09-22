defmodule ShortenIt.Repo do
  use Ecto.Repo,
    otp_app: :shorten_it,
    adapter: Ecto.Adapters.Postgres
end
