defmodule Myapp.Tracing do
  def get_spandex_opts(), do: get_opts(Application.get_all_env(:spandex_datadog))

  defp get_opts(config), do: [
    host: get_host(config),
    port: get_port(config),
    batch_size: get_batch_size(config),
    sync_threshold: get_sync_threshold(config),
    http: get_http(config)
  ]

  defp get_host(config), do: System.get_env("DATADOG_HOST") || config[:host] || "localhost"

  defp get_port(config), do: System.get_env("DATADOG_PORT") || config[:port] || 8126

  defp get_batch_size(config), do: System.get_env("SPANDEX_BATCH_SIZE") || config[:batch_size] || 10

  defp get_sync_threshold(config), do: System.get_env("SPANDEX_SYNC_THRESHOLD") || config[:sync_threshold] || 100

  defp get_http(config), do: config[:http] || HTTPoison

end
