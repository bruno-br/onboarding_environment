defmodule Myapp.Tracing.DatadogTracing do
  alias Myapp.Tracing.Tracer

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

  def get_datadog_traces_url() do
    spandex_opts = Myapp.Tracing.get_spandex_opts()
    host = spandex_opts[:host]
    port = spandex_opts[:port]

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
         resource: resource,
         service: service_atom,
         start: start,
         trace_id: trace_id,
         type: type_atom
       }),
       do: %{
         duration: (completion_time != nil && completion_time - start) || nil,
         meta: Map.merge(format_keyword_list(http, "http"), get_env()),
         span_id: span_id,
         name: name,
         resource: resource,
         service: Atom.to_string(service_atom),
         start: start,
         trace_id: trace_id,
         type: Atom.to_string(type_atom)
       }

  defp format_keyword_list(list, field_name) do
    if Keyword.keyword?(list) do
      Map.new(list, fn {key, val} ->
        {String.to_atom("#{field_name}.#{Atom.to_string(key)}"), to_string(val)}
      end)
    else
      list
    end
  end

  defp get_env(), do: %{env: Atom.to_string(Mix.env())}
end
