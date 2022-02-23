defmodule MailerAppWeb.Plugs.DatadogTracingPlugTest do
  use MailerAppWeb.ConnCase, async: false

  import Mock

  alias MailerAppWeb.Plugs.DatadogTracingPlug
  alias MailerApp.Tracing.DatadogTracing

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
