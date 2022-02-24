use Mix.Config

# Configures the endpoint
config :mailerapp, MailerAppWeb.Endpoint,
  instrumenters: [SpandexPhoenix.Instrumenter],
  url: [host: "localhost"],
  secret_key_base: "ghgIEqTJP5Pisyr6+kn7r44WQYgnEbwRYaVx5nNzqxj5LzEs1dsL0v4GCR9gmblm",
  render_errors: [view: MailerAppWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MailerApp.PubSub,
  live_view: [signing_salt: "7lA4T++c"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: [:request_id, :trace_id, :span_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mailerapp, MailerApp.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.ethereal.email",
  hostname: "smtp.ethereal.email",
  port: 587,
  username: "hattie.block86@ethereal.email",
  password: "htgt4E6TvMqUpBkbd3",
  tls: :if_available,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: false,
  retries: 1,
  no_mx_lookups: false,
  auth: :always

config :mailerapp, MailerApp.Tracing.Tracer,
  service: :mailerapp,
  adapter: SpandexDatadog.Adapter,
  type: :web

config :spandex, :decorators, tracer: MailerApp.Tracing.Tracer

config :spandex, :datadog,
  batch_size: 10,
  sync_threshold: 20

config :spandex,
  levels: [:low, :medium, :high],
  default_span_level: :low

config :spandex_phoenix, tracer: MailerApp.Tracing.Tracer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
