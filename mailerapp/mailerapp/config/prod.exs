use Mix.Config

config :mailerapp, MailerAppWeb.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :sentry,
  dsn: "http://9c4038263a2e40e9b6fddb8736a4fbd3@127.0.0.1:9000/2",
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  included_environments: [:prod]

# Do not print debug messages in production
config :logger, level: :info

import_config "prod.secret.exs"
