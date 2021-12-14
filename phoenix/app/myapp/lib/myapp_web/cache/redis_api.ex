defmodule MyappWeb.RedisApi do
  import Exredis

  def start() do
    Exredis.start_link()
  end

  def set(client, key, value) do
    with value_binary <- :erlang.term_to_binary(value),
         value_encoded <- Base.encode16(value_binary),
         "OK" <- query(client, ["SET", key, value_encoded]) do
      {:ok}
    else
      _ -> {:error}
    end
  end

  def get(client, key) do
    with value_encoded <- query(client, ["GET", key]),
         true <- value_encoded != :undefined,
         {:ok, value_binary = value_binary} <- Base.decode16(value_encoded),
         value <- :erlang.binary_to_term(value_binary) do
      {:ok, value}
    else
      _ -> {:error, :not_found}
    end
  end
end
