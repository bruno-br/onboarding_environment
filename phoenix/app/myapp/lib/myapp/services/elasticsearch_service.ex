defmodule Myapp.Services.ElasticsearchService do
  @moduledoc """
  API used to save and load data on cache using Redis
  """

  import Tirexs.HTTP

  def post(path, data), do: Tirexs.HTTP.post(path, data)
end
