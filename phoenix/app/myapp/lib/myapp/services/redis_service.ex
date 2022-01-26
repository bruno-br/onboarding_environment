defmodule Myapp.Services.RedisService do
  @moduledoc """
  API used to save and load data on cache using Redis
  """

  alias Myapp.Cache.RedisServer

  def set(key, value), do: set(key, value, 60)

  def set(key, value, expiration) do
    with value_binary <- :erlang.term_to_binary(value),
         value_encoded <- Base.encode16(value_binary),
         "OK" <- RedisServer.call_query(["SET", key, value_encoded]),
         "1" <- RedisServer.call_query(["EXPIRE", key, expiration]) do
      :ok
    else
      _ ->
        :error
    end
  end

  def get(key) do
    with value_encoded <- RedisServer.call_query(["GET", key]),
         true <- value_encoded != :undefined,
         {:ok, value_binary} <- Base.decode16(value_encoded),
         value <- :erlang.binary_to_term(value_binary) do
      {:ok, value}
    else
      _ -> {:error, :not_found}
    end
  end

  def del(key) do
    case RedisServer.call_query(["DEL", key]) do
      "1" -> :ok
      _ -> :error
    end
  end
end
