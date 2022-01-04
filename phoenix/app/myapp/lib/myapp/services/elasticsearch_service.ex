defmodule Myapp.Services.ElasticsearchService do
  @moduledoc """
  API used to save and load data on cache using Redis
  """

  @max_limit 10_000
  @index Application.get_env(:myapp, Myapp.Elasticsearch)[:index]

  import Tirexs.HTTP

  def get_index(), do: @index

  def post(path, data) do
    path
    |> get_path_with_index
    |> Tirexs.HTTP.post(data)
    |> format_response
  end

  def search(path, key, value) do
    path
    |> get_path_with_index
    |> tirexs_search_key_value(key, value)
    |> format_response
  end

  def list(path), do: list(path, @max_limit)

  def list(path, limit) when limit > @max_limit, do: list(path, @max_limit)

  def list(path, limit) do
    full_path = get_path_with_index(path)
    format_response(Tirexs.HTTP.post("#{full_path}/_search", %{size: limit}))
  end

  def clear() do
    Tirexs.HTTP.delete(@index)
    Tirexs.HTTP.put(@index)
  end

  def delete(path, key, value) do
    with full_path <- get_path_with_index(path),
         els_id <- search_and_get_els_id(full_path, key, value),
         {:ok, 200, details} <- tirexs_delete_by_els_id(full_path, els_id) do
      :ok
    else
      error -> :error
    end
  end

  defp search_and_get_els_id(full_path, key, value) do
    full_path
    |> tirexs_search_key_value(key, value)
    |> format_response_get_els_id
    |> List.first()
  end

  defp format_response({:ok, 200, %{:hits => %{:hits => hits_list}}}),
    do: {:ok, Enum.map(hits_list, fn x -> x[:_source] end)}

  defp format_response({:ok, 200}), do: {:ok, []}

  defp format_response(any), do: {:error, any}

  defp format_response_get_els_id({:ok, 200, %{:hits => %{:hits => hits_list}}}),
    do: Enum.map(hits_list, fn x -> x[:_id] end)

  defp get_path_with_index(path), do: "#{@index}/#{path}"

  defp tirexs_search_key_value(full_path, key, value),
    do: Tirexs.HTTP.get("#{full_path}/_search?q=#{key}:#{value}")

  defp tirexs_delete_by_els_id(full_path, els_id),
    do: Tirexs.HTTP.delete("#{full_path}/#{els_id}")
end
