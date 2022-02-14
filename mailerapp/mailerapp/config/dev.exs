use Mix.Config

config :mailerapp, MailerAppWeb.Endpoint,
  http: [port: 4444],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :sentry,
  dsn: "http://9c4038263a2e40e9b6fddb8736a4fbd3@127.0.0.1:9000/2",
  environment_name: :dev,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  included_environments: [:dev]
