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
  dsn: "http://23322d5f40914fe38ba74a89ce5fe680@127.0.0.1:9000/1",
  environment_name: :dev,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  included_environments: [:dev]
