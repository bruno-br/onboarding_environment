defmodule Myapp.Services.CsvFormatService do
  def get_csv_string(data) do
    data
    |> get_matrix()
    |> matrix_to_csv()
  end

  defp get_matrix([%{} | _] = maps_list) do
    headers = get_headers(maps_list)
    rows = get_rows(maps_list)
    matrix = [headers | rows]
  end

  defp get_matrix([] = maps_list), do: [[]]

  defp get_headers(maps_list) do
    maps_list
    |> List.first()
    |> Map.keys()
    |> Enum.map(&ensure_key_is_string(&1))
  end

  defp ensure_key_is_string(key), do: (is_atom(key) && Atom.to_string(key)) || key

  defp get_rows(maps_list), do: Enum.map(maps_list, &Map.values(&1))

  defp matrix_to_csv(matrix), do: Enum.map_join(matrix, "\n", &format_row(&1))

  defp format_row(row), do: Enum.map_join(row, ",", &"\"#{&1}\"")
end
