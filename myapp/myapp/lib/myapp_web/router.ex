defmodule MyappWeb.Router do
  use MyappWeb, :router
  use Spandex.Decorators

  alias MyappWeb.Plugs.LogPlug

  pipeline :api do
    plug(:accepts, ["json"])
    plug(LogPlug)
  end

  pipeline :exq do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
    plug(ExqUi.RouterPlug, namespace: "exq")
  end

  scope "/", MyappWeb do
    pipe_through(:api)
    resources("/products", ProductController, except: [:new, :edit])
    resources("/reports", ReportController, only: [:index])
  end

  scope "/exq", ExqUi do
    pipe_through(:exq)
    forward("/", RouterPlug.Router, :index)
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through([:fetch_session, :protect_from_forgery])
      live_dashboard("/dashboard", metrics: MyappWeb.Telemetry)
    end
  end
end
