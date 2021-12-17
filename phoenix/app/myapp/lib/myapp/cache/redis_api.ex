defmodule Myapp.RedisApi do
  import Exredis

  def start() do
    case Exredis.start_link() do
      {:ok, client} -> client
      _ -> nil
    end
  end

  def set(nil, _key, _value), do: :error

  def set(client, key, value), do: set(client, key, value, 10)

  def set(client, key, value, expiration) do
    with value_binary <- :erlang.term_to_binary(value),
         value_encoded <- Base.encode16(value_binary),
         "OK" <- query(client, ["SET", key, value_encoded]),
         "1" <- query(client, ["EXPIRE", key, expiration]) do
      :ok
    else
      _ -> :error
    end
  end

  def get(nil, _key), do: {:error, :bad_request}

  def get(client, key) do
    with value_encoded <- query(client, ["GET", key]),
         true <- value_encoded != :undefined,
         {:ok, value_binary} <- Base.decode16(value_encoded),
         value <- :erlang.binary_to_term(value_binary) do
      {:ok, value}
    else
      _ -> {:error, :not_found}
    end
  end
end
