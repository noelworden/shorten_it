defmodule ShortenIt.ShorteningTest do
  use ShortenIt.DataCase, async: true

  alias ShortenIt.Shortening
  alias ShortenIt.Shortening.Url

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
      assert {:error, :invalid_input} = Shortening.create_url(@invalid_original_url)
    end

    test "list_urls/0 returns all urls ordered by visit_count", context do
      %{url: url01} = context
      {:ok, url02} = Shortening.create_url(@valid_attrs)
      {:ok, url03} = Shortening.create_url(@valid_attrs)

      _visit01 = Shortening.get_url_and_update_counter(url02.shortened_url)
      _visit02 = Shortening.get_url_and_update_counter(url02.shortened_url)
      _visit03 = Shortening.get_url_and_update_counter(url02.shortened_url)
      _visit04 = Shortening.get_url_and_update_counter(url01.shortened_url)

      result =
        Shortening.list_urls()
        |> Enum.map(& &1.shortened_url)

      assert result == [url02.shortened_url, url01.shortened_url, url03.shortened_url]
    end

    test "get_url_and_update_counter/1 returns the url with given id", context do
      %{url: url} = context

      assert Shortening.get_url_and_update_counter(url.shortened_url) == url.original_url
    end

    test "get_url_and_update_counter/1 updates the `visit_count` field", context do
      %{url: url} = context

      _url = Shortening.get_url_and_update_counter(url.shortened_url)

      returned_url = Repo.get(Url, url.id)

      assert returned_url.visit_count == url.visit_count + 1
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
end
