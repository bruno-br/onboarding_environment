defmodule Myapp.Services.RedisService do
  @moduledoc """
  API used to save and load data on cache using Redis
  """

  use GenServer

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def init(_state), do: Exredis.start_link()

  def handle_call({:query, args}, _from, conn) do
    redis_response = Exredis.query(conn, args)
    {:reply, redis_response, conn}
  end

  def terminate(_reason, conn), do: Exredis.stop(conn)

  def call_query(args), do: GenServer.call(__MODULE__, {:query, args})

  def set(key, value), do: set(key, value, 60)

  def set(key, value, expiration) do
    with value_binary <- :erlang.term_to_binary(value),
         value_encoded <- Base.encode16(value_binary),
         "OK" <- call_query(["SET", key, value_encoded]),
         "1" <- call_query(["EXPIRE", key, expiration]) do
      :ok
    else
      _ -> :error
    end
  end

  def get(key) do
    with value_encoded <- call_query(["GET", key]),
         true <- value_encoded != :undefined,
         {:ok, value_binary} <- Base.decode16(value_encoded),
         value <- :erlang.binary_to_term(value_binary) do
      {:ok, value}
    else
      _ -> {:error, :not_found}
    end
  end

  def del(key) do
    case call_query(["DEL", key]) do
      "1" -> :ok
      _ -> :error
    end
  end
end
