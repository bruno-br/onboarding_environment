defmodule MailerApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {SpandexDatadog.ApiServer, get_spandex_opts()},
      # Start the Telemetry supervisor
      MailerAppWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MailerApp.PubSub},
      # Start the Endpoint (http/https)
      MailerAppWeb.Endpoint
      # Start a worker by calling: MailerApp.Worker.start_link(arg)
      # {MailerApp.Worker, arg}
    ]

    Logger.add_backend(Sentry.LoggerBackend)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MailerApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MailerAppWeb.Endpoint.config_change(changed, removed)
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
