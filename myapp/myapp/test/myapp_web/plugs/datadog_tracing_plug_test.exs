defmodule MyappWeb.Plugs.DatadogTracingPlugTest do
  use MyappWeb.ConnCase, async: false

  import Mock

  alias MyappWeb.Plugs.DatadogTracingPlug
  alias Myapp.Tracing.DatadogTracing

  describe "call/2" do
    test "calls DatadogTracing.send_trace/0", %{conn: conn} do
      with_mock(DatadogTracing,
        send_trace: fn -> :ok end
      ) do
        DatadogTracingPlug.call(conn, "opts")
        assert_called(DatadogTracing.send_trace())
      end
    end
  end
end
