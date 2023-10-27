defmodule ShortenIt.Workers.ProcessorWorker do
  use Oban.Worker
  import Ecto.Query, warn: false
  alias ShortenIt.Repo
  alias ShortenIt.Shortening
  alias ShortenIt.Shortening.Url

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"original_url" => original_url}}) do
    url = Repo.get_by(Url, original_url: original_url)
    Shortening.update_url(url, %{visit_count: url.visit_count + 1})
  end
end
