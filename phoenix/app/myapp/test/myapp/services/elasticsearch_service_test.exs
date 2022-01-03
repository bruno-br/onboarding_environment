defmodule Myapp.Services.ElasticsearchServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.ElasticsearchService

  import Tirexs.HTTP
  import Mock

  setup_all do
    %{path: "valid_path", data: "valid_data"}
  end

  describe "post/2" do
    test "calls Tirexs.HTTP.post function", %{path: path, data: data} do
      with_mock(Tirexs.HTTP,
        post: fn _path, data -> els_sucessful_response_mock(data) end
      ) do
        expected_response = {:ok, [data]}
        assert ElasticsearchService.post(path, data) == expected_response
      end
    end
  end

  defp els_sucessful_response_mock(value), do: {:ok, 200, %{hits: %{hits: [%{_source: value}]}}}
end
