use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :myapp, Myapp.Repo,
  database: "myapp_development_test",
  # database: "myapp_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost"

# pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :myapp, MyappWeb.Endpoint,
  http: [port: 4002],
  server: false

config :myapp, Myapp.Elasticsearch, index: "my_index_test"

config :myapp, MailerApi, url: "localhost:4444"

# Print only warnings and errors during test
config :logger, level: :warn
