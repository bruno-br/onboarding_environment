defmodule Myapp.Services.ElasticsearchService do
  @moduledoc """
  API used to save and load data on cache using Redis
  """

  @max_limit 10_000
  @index Application.get_env(:myapp, Myapp.Elasticsearch)[:index]

  import Tirexs.HTTP

  def post(path, data) do
    path
    |> get_path_with_index
    |> Tirexs.HTTP.post(data)
    |> format_response
  end

  def search(path, key, value) do
    full_path = get_path_with_index(path)
    format_response(Tirexs.HTTP.get("#{full_path}/_search?q=#{key}:#{value}"))
  end

  def list(path), do: list(path, @max_limit)

  def list(path, limit) when limit > @max_limit, do: list(path, @max_limit)

  def list(path, limit) do
    full_path = get_path_with_index(path)
    format_response(Tirexs.HTTP.post("#{full_path}/_search", %{size: limit}))
  end

  defp format_response({:ok, 200, %{:hits => %{:hits => hits_list}}}),
    do: {:ok, Enum.map(hits_list, fn x -> x[:_source] end)}

  defp format_response(any), do: {:error, any}

  defp get_path_with_index(path), do: "#{@index}/#{path}"
end
