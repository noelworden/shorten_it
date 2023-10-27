defmodule ShortenIt.ShorteningTest do
  use ShortenIt.DataCase, async: true
  use Oban.Testing, repo: ShortenIt.Repo

  alias ShortenIt.Shortening
  alias ShortenIt.Shortening.Url
  alias ShortenIt.Workers.ProcessorWorker

  @write_threshold 1_000_000
  @read_threshold @write_threshold

  @valid_attrs %{"original_url" => "http://www.example.com"}
  @invalid_original_url %{"original_url" => "httppp://www.example.com"}
  @invalid_visit_count %{"visit_count" => "bad data"}

  setup do
    {:ok, %Url{} = url} = Shortening.create_url(@valid_attrs)

    %{url: url}
  end

  describe "urls" do
    test "create_url/1 with valid data creates a url" do
      assert {:ok, %Url{} = url} = Shortening.create_url(@valid_attrs)
      assert url.original_url == "http://www.example.com"
      assert url.visit_count == 0
      assert String.length(url.shortened_url) == 11
    end

    test "create_url/1 with does not allow malformed urls to be saved" do
      assert {:error, %Ecto.Changeset{}} = Shortening.create_url(@invalid_original_url)
    end

    test "create_url/1 generates unique shortcodes" do
      {:ok, generator_calls} = Agent.start_link(fn -> 0 end)

      shortcode_generator = fn ->
        Agent.get_and_update(generator_calls, fn
          0 -> {"duplicate_shortcode", 1}
          calls -> {"unique_shortcode#{calls}", calls + 1}
        end)
      end

      attrs = %{original_url: "http://some-url.com", shortened_url: "duplicate_shortcode"}

      %Url{}
      |> Url.changeset(attrs)
      |> Repo.insert!()

      {:ok, url} = Shortening.create_url(%{"original_url" => "http://example.com"}, shortcode_generator)

      assert url.shortened_url == "unique_shortcode1"
      assert Agent.get(generator_calls, & &1) > 1

      Agent.stop(generator_calls)
    end

    test "list_urls/0 returns all urls ordered by visit_count", context do
      %{url: url01} = context
      {:ok, url02} = Shortening.create_url(@valid_attrs)
      {:ok, url03} = Shortening.create_url(@valid_attrs)

      {:ok, _url02} = Shortening.update_url(url02, %{visit_count: 5})
      {:ok, _url01} = Shortening.update_url(url01, %{visit_count: 2})

      result =
        Shortening.list_urls()
        |> Enum.map(& &1.shortened_url)

      assert result == [url02.shortened_url, url01.shortened_url, url03.shortened_url]
    end

    test "reroute_and_update_counter/1 returns the url when passed an existing shortened_url", context do
      %{url: url} = context

      assert Shortening.reroute_and_update_counter(url.shortened_url) == url.original_url
    end

    test "reroute_and_update_counter/1 returns nil when passed a non-existent shortened_url" do
      url = Shortening.reroute_and_update_counter("non_existent_shortened_url")

      assert is_nil(url)
    end

    test "reroute_and_update_counter/1 enqueues the update job", context do
      %{url: url} = context

      _url = Shortening.reroute_and_update_counter(url.shortened_url)

      assert_enqueued(worker: ProcessorWorker, args: %{original_url: url.original_url}, queue: :default)

      assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :default)

      returned_url = Repo.get(Url, url.id)
      assert returned_url.visit_count == url.visit_count + 1
    end

    test "reroute_and_update_counter/1 does not enqueues the update job if the url is nil" do
      url = Shortening.reroute_and_update_counter("non_existent_shortened_url")

      assert is_nil(url)
      refute_enqueued(worker: ProcessorWorker)
    end

    test "get_url!/1 returns the url with given id", context do
      %{url: url} = context
      assert Shortening.get_url!(url.id) == url
    end

    test "update_url/2 with valid data updates the url", context do
      %{url: url} = context

      update_attrs = %{
        visit_count: 5
      }

      assert {:ok, %Url{} = url} = Shortening.update_url(url, update_attrs)
      assert url.visit_count == 5
    end

    test "update_url/2 with invalid data returns error changeset", context do
      %{url: url} = context
      # require IEx; IEx.pry()
      assert {:error, %Ecto.Changeset{}} = Shortening.update_url(url, @invalid_visit_count)
      assert url == Shortening.get_url!(url.id)
    end

    test "change_url/1 returns a url changeset", context do
      %{url: url} = context
      assert %Ecto.Changeset{} = Shortening.change_url(url)
    end
  end

  describe "performance test" do
    test "can write 5x in under 1 second" do
      {time_taken, _result} =
        :timer.tc(fn ->
          Enum.each(1..5, fn _ ->
            Shortening.create_url(@valid_attrs)
          end)
        end)

      assert time_taken < @write_threshold
    end

    test "can read 25x in under 1 second", context do
      %{url: url} = context

      {time_taken, _result} =
        :timer.tc(fn ->
          Enum.each(1..25, fn _ ->
            Shortening.reroute_and_update_counter(url.shortened_url)
          end)
        end)

      assert time_taken < @read_threshold
    end
  end
end
