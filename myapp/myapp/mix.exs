defmodule Myapp.MixProject do
  use Mix.Project

  def project do
    [
      app: :myapp,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Myapp.Application, []},
      extra_applications: [:logger, :runtime_tools, :tirexs, :exq, :httpoison]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.13"},
      {:phoenix_ecto, "~> 4.4"},
      {:mongodb_ecto, github: "michalmuskala/mongodb_ecto"},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:redis, "~> 0.1"},
      {:exredis, ">= 0.2.4"},
      {:tirexs, "~> 0.8"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:mock, "~> 0.3.0", only: :test},
      {:exq, "~> 0.9"},
      {:exq_ui, "~> 0.10.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.8"},
      {:sentry, "~> 8.0"},
      {:spandex, "~> 3.0.3"},
      {:spandex_datadog, "~> 1.2"},
      {:spandex_phoenix, "~> 0.2"},
      {:spandex_ecto, "~> 0.2"},
      {:decorator, "~> 1.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "test"]
    ]
  end
end
