defmodule MailerApp.Tracing.DatadogTracing do
  alias MailerApp.Tracing.Tracer

  def send_trace() do
    with finished_spans_list <- finish_active_spans(),
         {:ok, trace} <- Tracer.finish_trace(),
         trace_spans_list <- get_trace_spans(trace),
         all_spans <- List.flatten(trace_spans_list, finished_spans_list),
         spans_formated <- format_spans(all_spans),
         {:ok, encoded_body} <- Poison.encode([spans_formated]) do
      send_to_datadog_agent(encoded_body)
    end
  end

  defp send_to_datadog_agent(trace) do
    url = get_datadog_traces_url()
    headers = [{"Content-type", "application/json"}]
    HTTPoison.put(url, trace, headers)
  end

  defp get_datadog_traces_url() do
    config = Application.get_all_env(:spandex_datadog)
    host = System.get_env("DATADOG_HOST") || config[:host] || "localhost"
    port = System.get_env("DATADOG_PORT") || config[:port] || 8126
    "#{host}:#{port}/v0.3/traces"
  end

  defp finish_active_spans() do
    case Tracer.current_span() do
      nil ->
        []

      _ ->
        {:ok, span} = Tracer.finish_span()
        span_list = finish_active_spans()
        [span | span_list]
    end
  end

  defp get_trace_spans(%{stack: span_list}), do: span_list

  defp format_spans(span_list), do: Enum.map(span_list, &format_span(&1))

  defp format_span(%{
         completion_time: completion_time,
         http: http,
         id: span_id,
         name: name,
         service: service_atom,
         start: start,
         trace_id: trace_id,
         type: type_atom
       }),
       do: %{
         duration: (completion_time != nil && completion_time - start) || nil,
         meta: format_keyword_list(http, "http"),
         #  meta: %{"http.status_code": "200"},
         span_id: span_id,
         name: name,
         service: Atom.to_string(service_atom),
         start: start,
         trace_id: trace_id,
         type: Atom.to_string(type_atom)
       }

  defp format_keyword_list(list, field_name) do
    if Keyword.keyword?(list) do
      list = Keyword.drop(list, [:query_string])
      Map.new(list, fn {key, val} ->
        {String.to_atom("#{field_name}.#{Atom.to_string(key)}"), to_string(val)}
      end)
    else
      list
    end
  end
end
