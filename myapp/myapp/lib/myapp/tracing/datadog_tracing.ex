defmodule Myapp.Tracing.DatadogTracing do
  alias Myapp.Tracing.Tracer

  def send_trace() do
    with {:ok, span} <- Tracer.finish_span(),
         {:ok, formated_span} <- format_span(span) do
      res = send_to_datadog_agent(formated_span)
      IO.puts("\n\n res - #{inspect(res)}")
    end
  end

  def send_to_datadog_agent(trace) do
    url = "http://localhost:8126/v0.3/traces"
    headers = [{"Content-type", "application/json"}]
    HTTPoison.put(url, trace, headers)
  end

  def format_span(%{
        completion_time: completion_time,
        http: http,
        id: span_id,
        name: name,
        service: service_atom,
        start: start,
        trace_id: trace_id,
        type: type_atom
      }) do
    Poison.encode([
      [
        %{
          duration: completion_time - start,
          http: http,
          span_id: span_id,
          name: name,
          service: Atom.to_string(service_atom),
          start: start,
          trace_id: trace_id,
          type: Atom.to_string(type_atom)
        }
      ]
    ])
  end
end
