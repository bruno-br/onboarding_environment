defmodule MailerApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
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
end
