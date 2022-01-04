defmodule Myapp.Services.ElasticsearchServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.ElasticsearchService

  import Tirexs.HTTP
  import Mock

  setup_all do
    %{
      path: "path",
      full_path: ElasticsearchService.get_index() <> "/path",
      data: "valid_data",
      key: "valid_key",
      value: "valid_value"
    }
  end

  setup_with_mocks([
    {Tirexs.HTTP, [], post: fn _path, data -> els_sucessful_response_mock(data) end},
    {Tirexs.HTTP, [], get: fn _path -> els_sucessful_response_mock() end}
  ]) do
    :ok
  end

  describe "post" do
    test "post data on elasticsearch", %{path: path, data: data, full_path: full_path} do
      assert ElasticsearchService.post(path, data) == {:ok, [data]}
      assert_called(Tirexs.HTTP.post(full_path, data))
    end
  end

  describe "search" do
    test "search data on elasticsearch", %{
      path: path,
      full_path: full_path,
      key: key,
      value: value
    } do
      assert ElasticsearchService.search(path, key, value) == {:ok, []}
      assert_called(Tirexs.HTTP.get("#{full_path}/_search?q=#{key}:#{value}"))
    end
  end

  describe "list" do
    test "list data from elasticsearch", %{
      path: path,
      full_path: full_path
    } do
      size = 1000
      assert ElasticsearchService.list(path, size) == {:ok, [%{size: size}]}
      assert_called(Tirexs.HTTP.post("#{full_path}/_search", %{size: size}))
    end
  end

  defp els_sucessful_response_mock(value), do: {:ok, 200, %{hits: %{hits: [%{_source: value}]}}}

  defp els_sucessful_response_mock(), do: {:ok, 200, %{hits: %{hits: []}}}
end
