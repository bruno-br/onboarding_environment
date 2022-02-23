defmodule Myapp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {SpandexDatadog.ApiServer, get_spandex_opts()},
      Myapp.Repo,
      MyappWeb.Telemetry,
      {Phoenix.PubSub, name: Myapp.PubSub},
      MyappWeb.Endpoint,
      Myapp.Cache.RedisSupervisor
    ]

    Logger.add_backend(Sentry.LoggerBackend)

    opts = [strategy: :one_for_one, name: Myapp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MyappWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp get_spandex_opts() do
    config = Application.get_all_env(:spandex_datadog)

    [
      host: System.get_env("DATADOG_HOST") || config[:host] || "localhost",
      port: System.get_env("DATADOG_PORT") || config[:port] || 8126,
      batch_size: System.get_env("SPANDEX_BATCH_SIZE") || config[:batch_size] || 10,
      sync_threshold: System.get_env("SPANDEX_SYNC_THRESHOLD") || config[:sync_threshold] || 100,
      http: config[:http] || HTTPoison
    ]
  end
end
