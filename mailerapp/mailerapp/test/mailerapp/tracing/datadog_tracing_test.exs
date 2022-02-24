defmodule MailerApp.Tracing.DatadogTracingTest do
  use MailerApp.DataCase, async: false

  import Mock

  alias MailerApp.Tracing.Tracer
  alias MailerApp.Tracing.DatadogTracing

  @span %{
    completion_time: 10,
    http: [method: "GET", status_code: 200, path_group: "/path", url: "/path"],
    id: "span_id",
    name: "name",
    resource: "GET /path",
    service: :MailerApp_test,
    start: 0,
    trace_id: "trace_id",
    type: :web
  }
  @trace %{stack: [@span]}
  @trace_encoded "[[{\"type\":\"web\",\"trace_id\":\"trace_id\",\"start\":0,\"span_id\":\"span_id\",\"service\":\"MailerApp_test\",\"resource\":\"GET /path\",\"name\":\"name\",\"meta\":{\"http.url\":\"/path\",\"http.status_code\":\"200\",\"http.path_group\":\"/path\",\"http.method\":\"GET\"},\"duration\":10}]]"

  setup_all do
    [
      url: get_datadog_traces_url(),
      headers: [{"Content-type", "application/json"}]
    ]
  end

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
    },
    {
      Poison,
      [],
      encode: fn _trace -> {:ok, @trace_encoded} end
    }
  ]) do
    :ok
  end

  describe "send_trace/0" do
    test "call datadog agent API with correct params", %{url: url, headers: headers} do
      DatadogTracing.send_trace()
      assert_called(HTTPoison.put(url, @trace_encoded, headers))
    end
  end

  def get_datadog_traces_url() do
    spandex_opts = MailerApp.Tracing.get_spandex_opts()
    host = spandex_opts[:host]
    port = spandex_opts[:port]

    "#{host}:#{port}/v0.3/traces"
  end
end
