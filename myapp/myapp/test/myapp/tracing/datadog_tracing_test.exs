defmodule Myapp.Tracing.DatadogTracingTest do
  use Myapp.DataCase, async: false

  import Mock

  alias Myapp.Tracing.Tracer
  alias Myapp.Tracing.DatadogTracing

  @span %{
    completion_time: 10,
    http: [method: "GET", status_code: 200, path_group: "/path", url: "/path"],
    id: "span_id",
    name: "name",
    resource: "GET /path",
    service: :myapp_test,
    start: 0,
    trace_id: "trace_id",
    type: :web
  }
  @trace %{stack: [@span]}
  @trace_encoded "[[{\"type\":\"web\",\"trace_id\":\"trace_id\",\"start\":0,\"span_id\":\"span_id\",\"service\":\"myapp_test\",\"resource\":\"GET /path\",\"name\":\"name\",\"meta\":{\"http.url\":\"/path\",\"http.status_code\":\"200\",\"http.path_group\":\"/path\",\"http.method\":\"GET\"},\"duration\":10}]]"

  setup_with_mocks([
    {
      Tracer,
      [],
      finish_trace: fn -> {:ok, @trace} end,
      current_span: fn -> nil end,
      finish_span: fn -> {:ok, @span} end
    },
    {
      HTTPoison,
      [],
      put: fn _url, _body, _headers -> :ok end
    }
  ]) do
    :ok
  end

  describe "send_trace/0" do
    test "call datadog agent API with correct params" do
      url = DatadogTracing.get_datadog_traces_url
      headers = [{"Content-type", "application/json"}]

      DatadogTracing.send_trace()
      assert_called(HTTPoison.put(url, @trace_encoded, headers))
    end
  end
end
