defmodule MyappWeb.Plugs.LogPlugTest do
  use MyappWeb.ConnCase, async: false

  alias MyappWeb.Plugs.LogPlug

  import Mock
  import Tirexs.HTTP

  describe "call/2" do
    test "posts log with data from connection", %{conn: conn} do
      with_mock(Tirexs.HTTP, post: fn _path, log -> log end) do
        LogPlug.call(conn, "opts")

        assert_called(
          Tirexs.HTTP.post(
            "/my_index/logs",
            :meck.is(fn log ->
              assert log[:date] != nil
              assert log[:method] == conn.method
              assert log[:request_path] == conn.request_path
              assert log[:req_headers] == conn.req_headers
              assert log[:body_params] == conn.body_params
            end)
          )
        )
      end
    end
  end
end
