defmodule Myapp.Services.CsvFormatServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.CsvFormatService

  setup_all do
    %{
      map_list_string_keys: [%{"a" => 1, "b" => 2}, %{"a" => 10, "b" => 20}],
      map_list_atom_keys: [%{a: 1, b: 2}, %{a: 10, b: 20}],
      invalid_data: nil,
      expected_response: {:ok, "\"a\",\"b\"\n\"1\",\"2\"\n\"10\",\"20\""}
    }
  end

  describe "get_csv_string/1" do
    test "returns expected response with string keys", %{
      map_list_string_keys: data,
      expected_response: expected_response
    } do
      assert CsvFormatService.get_csv_string(data) == expected_response
    end

    test "returns expected response with atom keys", %{
      map_list_atom_keys: data,
      expected_response: expected_response
    } do
      assert CsvFormatService.get_csv_string(data) == expected_response
    end

    test "replace quotation marks with single quotes" do
      data = [%{a: "1\"\"\""}]
      expected_reponse = {:ok, "\"a\"\n\"1'''\""}
      assert CsvFormatService.get_csv_string(data) == expected_reponse
    end

    test "returns error when data is invalid", %{
      invalid_data: data
    } do
      expected_reponse = {:error, :invalid_format}
      assert CsvFormatService.get_csv_string(data) == expected_reponse
    end
  end
end
