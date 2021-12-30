defmodule Myapp.Services.ElasticsearchService do
  @moduledoc """
  API used to save and load data on cache using Redis
  """

  import Tirexs.HTTP

  def post(path, data), do: Tirexs.HTTP.post(path, data)

  def search(path, key, value) do
    case Tirexs.HTTP.get("#{path}/_search?q=#{key}:#{value}") do
      {:ok, 200, search_result} -> {:ok, search_result.hits.hits}
      _ -> {:error, :not_found}
    end
  end
end
