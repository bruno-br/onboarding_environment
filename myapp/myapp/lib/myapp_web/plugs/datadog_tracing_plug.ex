defmodule MyappWeb.Plugs.DatadogTracingPlug do
  import Plug.Conn

  alias Myapp.Tracing.DatadogTracing
  alias Myapp.Tracing.Tracer

  def init(props) do
    props
  end

  def call(conn, _opts) do
    DatadogTracing.send_trace()
    conn
  end
end
