defmodule Myapp.Services.ElasticsearchServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.ElasticsearchService

  import Tirexs.HTTP
  import Mock

  setup_all do
    %{path: "valid_path", data: "valid_data", key: "valid_key", value: "valid_value"}
  end

  setup_with_mocks([
    {Tirexs.HTTP, [], post: fn _path, data -> els_sucessful_response_mock(data) end},
    {Tirexs.HTTP, [], get: fn _path -> els_sucessful_response_mock() end}
  ]) do
    :ok
  end

  describe "post" do
    test "calls Tirexs.HTTP.post function", %{path: path, data: data} do
      expected_response = {:ok, [data]}
      assert ElasticsearchService.post(path, data) == expected_response
    end
  end

  defp els_sucessful_response_mock(value), do: {:ok, 200, %{hits: %{hits: [%{_source: value}]}}}

  defp els_sucessful_response_mock(), do: {:ok, 200, %{hits: %{hits: []}}}
end
