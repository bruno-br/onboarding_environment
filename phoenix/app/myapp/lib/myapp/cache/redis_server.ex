defmodule Myapp.Cache.RedisServer do
  use GenServer

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def init(_state), do: Exredis.start_link()

  def handle_call({:query, args}, _from, conn) do
    redis_response = Exredis.query(conn, args)
    {:reply, redis_response, conn}
  end

  def terminate(_reason, conn), do: Exredis.stop(conn)

  def call_query(args), do: GenServer.call(__MODULE__, {:query, args})
end
