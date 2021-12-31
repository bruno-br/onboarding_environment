defmodule Myapp.Services.ElasticsearchService do
  @moduledoc """
  API used to save and load data on cache using Redis
  """

  import Tirexs.HTTP

  def post(path, data), do: format_response(Tirexs.HTTP.post(path, data))

  def search(path, key, value),
    do: format_response(Tirexs.HTTP.get("#{path}/_search?q=#{key}:#{value}"))

  defp format_response({:ok, 200, %{:hits => %{:hits => hits_list}}}),
    do: {:ok, Enum.map(hits_list, fn x -> x[:_source] end)}

  defp format_response(any), do: {:error, :bad_request}
end
