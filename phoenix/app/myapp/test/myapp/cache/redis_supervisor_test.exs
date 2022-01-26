defmodule Myapp.Cache.RedisSupervisorTest do
  use Myapp.DataCase, async: false

  alias Myapp.Cache.RedisSupervisor

  import Mock

  @opts "opts"
  @start_link_success_response {:ok, "pid"}
  @init_success_response {:ok, "conn"}

  setup_with_mocks([
    {Supervisor, [],
     start_link: fn _module, _state, _name -> @start_link_success_response end,
     init: fn _children, _strategy -> @init_success_response end}
  ]) do
    :ok
  end

  describe "start_link/1" do
    test "calls Supervisor.start_link with correct args" do
      assert RedisSupervisor.start_link(@opts) == @start_link_success_response
      assert_called(Supervisor.start_link(:_, :ok, @opts))
    end
  end

  describe "init/1" do
    test "calls Supervisor.init with correct args" do
      children = [
        Myapp.Cache.RedisServer
      ]
      assert RedisSupervisor.init(:ok) == @init_success_response
      assert_called(Supervisor.init(children, strategy: :one_for_one))
    end
  end
end
