defmodule Myapp.Services.ElasticsearchService do
  @moduledoc """
  API used to save and load data on cache using Redis
  """

  @max_limit 10_000

  def get_index(), do: Application.get_env(:myapp, Myapp.Elasticsearch)[:index]

  def post(document, data) do
    document
    |> tirexs_post(data)
    |> format_response()
  end

  def search(document, key, value), do: search(document, [{key, value}])

  def search(document, [{_key, _value} | _] = filters) do
    document
    |> tirexs_search(filters)
    |> format_response()
  end

  def list(document), do: list(document, @max_limit)

  def list(document, limit) when limit > @max_limit, do: list(document, @max_limit)

  def list(document, limit) do
    document
    |> tirexs_search([], %{size: limit})
    |> format_response()
  end

  def clear() do
    Tirexs.HTTP.delete(get_index())
    Tirexs.HTTP.put(get_index())
  end

  def delete(document, key, value) do
    with els_id <- find_els_id(document, key, value),
         {:ok, 200, details} <- tirexs_delete_by_els_id(document, els_id) do
      format_response({:ok, 200, details})
    else
      error -> {:error, error}
    end
  end

  def update(document, key, value, new_data) do
    with els_id <- find_els_id(document, key, value),
         {:ok, _status, _details} <- tirexs_update_by_els_id(document, els_id, new_data) do
      :ok
    else
      error -> {:error, error}
    end
  end

  defp format_response({:ok, 200, %{:hits => %{:hits => hits_list}}}),
    do: {:ok, Enum.map(hits_list, & &1[:_source])}

  defp format_response({:ok, 200}), do: {:ok, []}

  defp format_response({:ok, 201, %{:created => true}}), do: {:ok, :created}

  defp format_response(any), do: {:error, any}

  defp format_response_get_els_id({:ok, 200, %{:hits => %{:hits => hits_list}}}),
    do: Enum.map(hits_list, & &1[:_id])

  defp find_els_id(document, key, value) do
    with search_result <- tirexs_search(document, [{key, value}]),
         els_id_list <- format_response_get_els_id(search_result),
         1 <- length(els_id_list) do
      List.first(els_id_list)
    else
      _ -> :not_found
    end
  end

  defp tirexs_post(document, data),
    do: Tirexs.HTTP.post("#{get_doc_url(document)}", data)

  defp tirexs_search(document, filters, body) do
    document
    |> get_search_url(filters)
    |> Tirexs.HTTP.post(body)
  end

  defp tirexs_search(document, filters) do
    document
    |> get_search_url(filters)
    |> Tirexs.HTTP.get()
  end

  defp tirexs_delete_by_els_id(document, els_id),
    do: Tirexs.HTTP.delete("#{get_doc_url(document)}/#{els_id}")

  defp tirexs_update_by_els_id(document, els_id, new_data),
    do: Tirexs.HTTP.post("#{get_doc_url(document)}/#{els_id}", new_data)

  defp get_doc_url(document), do: "#{get_index()}/#{document}"

  defp get_search_url(document, filters),
    do: "#{get_doc_url(document)}/_search?#{generate_query(filters)}"

  defp generate_query([{_key, _value} | _] = filters),
    do: "q=" <> Enum.map_join(filters, "%20AND%20", fn {key, value} -> "#{key}:#{value}" end)

  defp generate_query(_), do: ""
end
