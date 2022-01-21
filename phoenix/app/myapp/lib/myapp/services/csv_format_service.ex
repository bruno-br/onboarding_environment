defmodule Myapp.Services.CsvFormatService do
  def get_csv_string(data) do
    with {:ok, matrix} <- get_matrix(data),
         csv <- matrix_to_csv(matrix) do
      {:ok, csv}
    else
      error -> {:error, error}
    end
  end

  defp get_matrix([%{} = first_element | _] = maps_list) do
    headers = get_headers(first_element)
    rows = get_rows(maps_list)
    matrix = [headers | rows]

    {:ok, matrix}
  end

  defp get_matrix([]), do: {:ok, [[]]}

  defp get_headers(first_element) do
    first_element
    |> Map.keys()
    |> Enum.map(&ensure_key_is_string(&1))
  end

  defp ensure_key_is_string(key),
    do: (is_atom(key) && Atom.to_string(key)) || key

  defp get_rows(maps_list),
    do: Enum.map(maps_list, &Map.values(&1))

  defp matrix_to_csv(matrix),
    do: Enum.map_join(matrix, "\n", &format_row(&1))

  defp format_row(row),
    do: Enum.map_join(row, ",", &"\"#{replace_quotation_marks(&1)}\"")

  defp replace_quotation_marks(string) when is_bitstring(string),
    do: String.replace(string, "\"", "'")

  defp replace_quotation_marks(not_string),
    do: not_string
end
