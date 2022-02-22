defmodule MailerAppWeb.Plugs.DatadogTracingPlug do
  import Plug.Conn

  alias MailerApp.Tracing.DatadogTracing
  alias MailerApp.Tracing.Tracer

  def init(props) do
    props
  end

  def call(conn, _opts) do
    DatadogTracing.send_trace()
    conn
  end
end
