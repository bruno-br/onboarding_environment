defmodule Myapp.Cache.RedisServerTest do
  use Myapp.DataCase, async: false

  alias Myapp.Cache.RedisServer

  import Mock

  @opts "opts"
  @start_link_success_response {:ok, "pid"}
  @call_success_response {:ok, "pid"}
  @redis_query_response "OK"

  setup_with_mocks([
    {GenServer, [],
     start_link: fn _module, _state, _name -> @start_link_success_response end,
     call: fn _module, _request -> @call_success_response end},
    {Exredis, [],
     start_link: fn -> @start_link_success_response end,
     query: fn _conn, _args -> @redis_query_response end,
     stop: fn _conn -> :ok end}
  ]) do
    :ok
  end

  describe "start_link/1" do
    test "calls GenServer.start_link with correct args" do
      assert RedisServer.start_link(@opts) == @start_link_success_response
      assert_called(GenServer.start_link(:_, @opts, :_))
    end
  end

  describe "init/1" do
    test "calls Exredis.start_link" do
      assert RedisServer.init(@opts) == @start_link_success_response
      assert_called(Exredis.start_link())
    end
  end

  describe "handle_call/3" do
    test "calls Exredis.query with correct args" do
      expected_response = {:reply, @redis_query_response, "conn"}
      assert RedisServer.handle_call({:query, @opts}, "from", "conn") == expected_response
      assert_called(Exredis.query("conn", @opts))
    end
  end

  describe "terminate/2" do
    test "calls Exredis.stop" do
      RedisServer.terminate("reason", "conn")
      assert_called(Exredis.stop("conn"))
    end
  end

  describe "call_query/1" do
    test "calls GenServer.call with correct args" do
      assert RedisServer.call_query(@opts) == @call_success_response
      assert_called(GenServer.call(:_, {:query, @opts}))
    end
  end
end
