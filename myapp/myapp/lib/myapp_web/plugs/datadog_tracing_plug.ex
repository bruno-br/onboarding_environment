defmodule MyappWeb.Plugs.DatadogTracingPlug do
  alias Myapp.Tracing.DatadogTracing

  def init(props) do
    props
  end

  def call(conn, _opts) do
    DatadogTracing.send_trace()
    conn
  end
end
