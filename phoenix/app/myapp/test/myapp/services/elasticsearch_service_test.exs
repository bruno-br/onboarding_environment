defmodule Myapp.Services.ElasticsearchServiceTest do
  use Myapp.DataCase, async: false

  import Mock

  alias Myapp.Services.ElasticsearchService

  setup_all do
    %{
      document: "document",
      full_path: ElasticsearchService.get_index() <> "/document",
      data: "valid_data",
      key: "valid_key",
      value: "valid_value"
    }
  end

  setup_with_mocks([
    {Tirexs.HTTP, [], post: fn _document, data -> els_sucessful_response_mock(data) end},
    {Tirexs.HTTP, [], get: fn _document -> els_sucessful_response_mock("search_result") end},
    {Tirexs.HTTP, [], delete: fn _index -> els_sucessful_response_mock() end},
    {Tirexs.HTTP, [], put: fn _index -> els_sucessful_response_mock() end}
  ]) do
    :ok
  end

  describe "post" do
    test "post data on elasticsearch", %{document: document, data: data, full_path: full_path} do
      assert ElasticsearchService.post(document, data) == {:ok, [data]}
      assert_called(Tirexs.HTTP.post(full_path, data))
    end
  end

  describe "search" do
    test "search data on elasticsearch", %{
      document: document,
      full_path: full_path,
      key: key,
      value: value
    } do
      assert ElasticsearchService.search(document, key, value) == {:ok, ["search_result"]}
      assert_called(Tirexs.HTTP.get("#{full_path}/_search?q=#{key}:#{value}"))
    end
  end

  describe "list" do
    test "list data from elasticsearch", %{
      document: document,
      full_path: full_path
    } do
      size = 1000
      assert ElasticsearchService.list(document, size) == {:ok, [%{size: size}]}
      assert_called(Tirexs.HTTP.post("#{full_path}/_search?", %{size: size}))
    end

    test "limit size to 10000", %{
      document: document,
      full_path: full_path
    } do
      invalid_size = 999_999
      max_size = 10_000
      assert ElasticsearchService.list(document, invalid_size) == {:ok, [%{size: max_size}]}
      assert_called(Tirexs.HTTP.post("#{full_path}/_search?", %{size: max_size}))
    end
  end

  describe "clear" do
    test "recreates index" do
      els_index = ElasticsearchService.get_index()
      ElasticsearchService.clear()
      assert_called(Tirexs.HTTP.delete(els_index))
      assert_called(Tirexs.HTTP.put(els_index))
    end
  end

  describe "delete" do
    test "deletes item found on search", %{
      document: document,
      key: key,
      value: value
    } do
      assert ElasticsearchService.delete(document, key, value) == {:ok, []}
      assert_called(Tirexs.HTTP.delete(:_))
    end
  end

  describe "update" do
    test "updates item found on search", %{
      document: document,
      key: key,
      value: value
    } do
      assert ElasticsearchService.update(document, key, value, "data") == {:ok, ["data"]}
      assert_called(Tirexs.HTTP.post(:_, "data"))
    end
  end

  defp els_sucessful_response_mock(value),
    do: {:ok, 200, %{hits: %{hits: [%{_source: value, _id: "valid_id"}]}}}

  defp els_sucessful_response_mock(), do: {:ok, 200, %{hits: %{hits: []}}}
end
