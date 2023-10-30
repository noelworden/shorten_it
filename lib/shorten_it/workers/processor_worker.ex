defmodule ShortenIt.Workers.ProcessorWorker do
  @moduledoc """
  An Oban processor to update the `visit_count`.
  """

  use Oban.Worker
  import Ecto.Query, warn: false
  alias ShortenIt.Shortening
  alias ShortenIt.Shortening.Url

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url_map}}) do
    %{
      "id" => id,
      "original_url" => original_url,
      "shortened_url" => shortened_url,
      "visit_count" => visit_count,
      "inserted_at" => inserted_at,
      "updated_at" => updated_at
    } = url_map

    url = %Url{
      id: id,
      original_url: original_url,
      shortened_url: shortened_url,
      visit_count: visit_count,
      inserted_at: inserted_at,
      updated_at: updated_at
    }

    Shortening.update_url(url, %{visit_count: url.visit_count + 1})
  end
end
