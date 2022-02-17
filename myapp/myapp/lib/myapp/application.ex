defmodule Myapp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    spandex_opts =
      [
        host: System.get_env("DATADOG_HOST") || "localhost",
        port: System.get_env("DATADOG_PORT") || 8126,
        batch_size: System.get_env("SPANDEX_BATCH_SIZE") || 10,
        sync_threshold: System.get_env("SPANDEX_SYNC_THRESHOLD") || 100,
        http: HTTPoison
      ]

    children = [
      {SpandexDatadog.ApiServer, spandex_opts},
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
end
