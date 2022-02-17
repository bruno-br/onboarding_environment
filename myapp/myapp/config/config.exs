# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :myapp,
  ecto_repos: [Myapp.Repo]

# Configures the endpoint
config :myapp, MyappWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RYdsnixXkf7WLeAYqt+4HVDXBHUQ8hTR6i2TqqFU/IO46n4JjwZmQOAjxt0GtkTr",
  render_errors: [view: MyappWeb.ErrorView, accepts: ~w(json), layout: false, format: "json"],
  pubsub_server: Myapp.PubSub,
  live_view: [signing_salt: "knpjupim"]

config :myapp, Myapp.Tracing.Tracer,
  service: :myapp,
  adapter: SpandexDatadog.Adapter,
  disabled?: false,
  env: "DEV"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :trace_id, :span_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :exredis,
  host: "127.0.0.1",
  port: 6379,
  password: "",
  db: 0,
  reconnect: :no_reconnect,
  max_queue: :infinity

config :exq,
  name: Exq,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq",
  concurrency: :infinite,
  queues: ["report"],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 25,
  mode: :default,
  shutdown_timeout: 5000

config :exq_ui,
  webport: 4040,
  web_namespace: "",
  server: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
