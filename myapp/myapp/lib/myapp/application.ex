defmodule Myapp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {SpandexDatadog.ApiServer, Myapp.Tracing.get_spandex_opts()},
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
