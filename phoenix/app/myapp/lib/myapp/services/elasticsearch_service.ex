defmodule Myapp.Services.ElasticsearchService do
  @moduledoc """
  API used to save and load data on cache using Redis
  """

  @max_limit 10_000
  @index Application.get_env(:myapp, Myapp.Elasticsearch)[:index]

  import Tirexs.HTTP

  def get_index(), do: @index

  def post(document, data) do
    document
    |> tirexs_post(data)
    |> format_response()
  end

  def search(document, key, value) do
    document
    |> tirexs_search(key, value)
    |> format_response()
  end

  def list(document), do: list(document, @max_limit)

  def list(document, limit) when limit > @max_limit, do: list(document, @max_limit)

  def list(document, limit) do
    document
    |> tirexs_search(%{size: limit})
    |> format_response()
  end

  def clear() do
    Tirexs.HTTP.delete(@index)
    Tirexs.HTTP.put(@index)
  end

  def delete(document, key, value) do
    with els_id <- search_and_get_els_id(document, key, value),
         {:ok, 200, details} <- tirexs_delete_by_els_id(document, els_id) do
      format_response({:ok, 200, details})
    else
      error -> {:error, error}
    end
  end

  def update(document, key, value, new_data) do
    with els_id <- search_and_get_els_id(document, key, value),
         {:ok, 200, details} <- tirexs_update_by_els_id(document, els_id, new_data) do
      format_response({:ok, 200, details})
    else
      error -> {:error, error}
    end
  end

  defp search_and_get_els_id(document, key, value) do
    document
    |> tirexs_search(key, value)
    |> format_response_get_els_id()
    |> List.first()
  end

  defp format_response({:ok, 200, %{:hits => %{:hits => hits_list}}}),
    do: {:ok, Enum.map(hits_list, fn x -> x[:_source] end)}

  defp format_response({:ok, 200}), do: {:ok, []}

  defp format_response(any), do: {:error, any}

  defp format_response_get_els_id({:ok, 200, %{:hits => %{:hits => hits_list}}}),
    do: Enum.map(hits_list, fn x -> x[:_id] end)

  defp get_full_path(document), do: "#{@index}/#{document}"

  defp tirexs_post(document, data),
    do: Tirexs.HTTP.post("#{get_full_path(document)}", data)

  defp tirexs_search(document, key, value, body),
    do: Tirexs.HTTP.post("#{get_full_path(document)}/_search?q=#{key}:#{value}", body)

  defp tirexs_search(document, body),
    do: Tirexs.HTTP.post("#{get_full_path(document)}/_search", body)

  defp tirexs_search(document, key, value),
    do: Tirexs.HTTP.get("#{get_full_path(document)}/_search?q=#{key}:#{value}")

  defp tirexs_delete_by_els_id(document, els_id),
    do: Tirexs.HTTP.delete("#{get_full_path(document)}/#{els_id}")

  defp tirexs_update_by_els_id(document, els_id, new_data),
    do: Tirexs.HTTP.post("#{get_full_path(document)}/#{els_id}", new_data)
end
