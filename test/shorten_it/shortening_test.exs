defmodule ShortenIt.ShorteningTest do
  use ShortenIt.DataCase, async: true

  alias ShortenIt.Shortening
  alias ShortenIt.Shortening.Url

  @valid_attrs %{original_url: "some original_url"}

  describe "urls" do
    test "create_url/1 with valid data creates a url" do
      assert {:ok, %Url{} = url} = Shortening.create_url(@valid_attrs)
      assert url.original_url == "some original_url"
      assert url.visit_count == 0
      assert String.length(url.shortened_url) == 11
    end

    test "create_url/1 with valid data creates a url does not allow" do
      {:ok, %Url{} = url} = Shortening.create_url(@valid_attrs)

      inserted_attrs = %{original_url: "another_url", shortened_url: url.shortened_url}

      assert {:error, changeset} =
               %Url{}
               |> Url.changeset(inserted_attrs)
               |> Repo.insert()

      assert {:shortened_url, {"has already been taken", _}} = List.first(changeset.errors)
    end

    test "list_urls/0 returns all urls ordered by visit_count" do
      {:ok, url01} = Shortening.create_url(@valid_attrs)
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

    test "get_url_and_update_counter/1 returns the url with given id" do
      {:ok, %Url{} = url} = Shortening.create_url(@valid_attrs)

      assert Shortening.get_url_and_update_counter(url.shortened_url) == url.original_url
    end

    test "get_url_and_update_counter/1 updates the `visit_count` field" do
      {:ok, %Url{} = url} = Shortening.create_url(@valid_attrs)

      _url = Shortening.get_url_and_update_counter(url.shortened_url)

      returned_url = Repo.get(Url, url.id)

      assert returned_url.visit_count == url.visit_count + 1
    end

    #   test "create_url/1 with invalid data returns error changeset" do
    #     assert {:error, %Ecto.Changeset{}} = Shortening.create_url(@invalid_attrs)
    #   end

    #   test "update_url/2 with valid data updates the url" do
    #     url = url_fixture()

    #     update_attrs = %{
    #       original_url: "some updated original_url",
    #       shortened_url: "some updated shortened_url",
    #       visit_count: 43
    #     }

    #     assert {:ok, %Url{} = url} = Shortening.update_url(url, update_attrs)
    #     assert url.original_url == "some updated original_url"
    #     assert url.shortened_url == "some updated shortened_url"
    #     assert url.visit_count == 43
    #   end

    #   test "update_url/2 with invalid data returns error changeset" do
    #     url = url_fixture()
    #     assert {:error, %Ecto.Changeset{}} = Shortening.update_url(url, @invalid_attrs)
    #     assert url == Shortening.get_url!(url.id)
    #   end

    #   test "delete_url/1 deletes the url" do
    #     url = url_fixture()
    #     assert {:ok, %Url{}} = Shortening.delete_url(url)
    #     assert_raise Ecto.NoResultsError, fn -> Shortening.get_url!(url.id) end
    #   end

    #   test "change_url/1 returns a url changeset" do
    #     url = url_fixture()
    #     assert %Ecto.Changeset{} = Shortening.change_url(url)
    #   end
  end
end
