defmodule Myapp.Repo do
  use Ecto.Repo,
    otp_app: :myapp,
    adapter: Mongo.Ecto,
    loggers: [
      {Ecto.LogEntry, :log, [:info]},
      {SpandexEcto.EctoLogger, :trace, ["myapp_repo"]}
    ]
end
