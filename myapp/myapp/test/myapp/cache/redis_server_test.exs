defmodule Myapp.Cache.RedisServerTest do
  use Myapp.DataCase, async: false

  alias Myapp.Cache.RedisServer

  import Mock

  @opts "opts"
  @start_link_success_response {:ok, "pid"}
  @call_success_response {:ok, "pid"}
  @redis_query_response "OK"

  describe "start_link/1" do
    test_with_mock("calls GenServer.start_link with correct args", GenServer, [],
      start_link: fn _module, _state, _name -> @start_link_success_response end
    ) do
      assert RedisServer.start_link(@opts) == @start_link_success_response
      assert_called(GenServer.start_link(:_, @opts, :_))
    end
  end

  describe "init/1" do
    test_with_mock("calls Exredis.start_link", Exredis, [],
      start_link: fn -> @start_link_success_response end
    ) do
      assert RedisServer.init(@opts) == @start_link_success_response
      assert_called(Exredis.start_link())
    end
  end

  describe "handle_call/3" do
    test_with_mock("calls Exredis.query with correct args", Exredis, [],
      query: fn _conn, _args -> @redis_query_response end
    ) do
      expected_response = {:reply, @redis_query_response, "conn"}
      assert RedisServer.handle_call({:query, @opts}, "from", "conn") == expected_response
      assert_called(Exredis.query("conn", @opts))
    end
  end

  describe "terminate/2" do
    test_with_mock("calls Exredis.stop", Exredis, [], stop: fn _conn -> :ok end) do
      RedisServer.terminate("reason", "conn")
      assert_called(Exredis.stop("conn"))
    end
  end

  describe "call_query/1" do
    test_with_mock("calls GenServer.call with correct args", GenServer, [],
      call: fn _module, _request -> @call_success_response end,
      whereis: fn _server -> :ok end
    ) do
      assert RedisServer.call_query(@opts) == @call_success_response
      assert_called(GenServer.call(:_, {:query, @opts}))
    end
  end
end
