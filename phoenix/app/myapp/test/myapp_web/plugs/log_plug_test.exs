defmodule MyappWeb.Plugs.LogPlugTest do
  use MyappWeb.ConnCase, async: true

  alias MyappWeb.Plugs.LogPlug
  alias Myapp.Services.ElasticsearchService

  import Mock

  describe "call/2" do
    test "posts log with data from connection", %{conn: conn} do
      with_mock(ElasticsearchService, post: fn _path, log -> log end) do
        LogPlug.call(conn, "opts")

        assert_called(
          ElasticsearchService.post(
            :_,
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
