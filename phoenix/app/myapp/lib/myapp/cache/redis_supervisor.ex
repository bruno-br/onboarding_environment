defmodule Myapp.Cache.RedisSupervisor do
  use Supervisor

  def start_link(opts), do: Supervisor.start_link(__MODULE__, :ok, opts)

  def init(:ok) do
    children = [
      Myapp.Cache.RedisServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
