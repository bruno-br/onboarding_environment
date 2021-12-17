defmodule MyappWeb.Router do
  use MyappWeb, :router

  alias MyappWeb.Plugs.LogPlug

  pipeline :api do
    plug :accepts, ["json"]
    plug(LogPlug)
  end

  scope "/", MyappWeb do
    pipe_through :api
    resources "/products", ProductController, except: [:new, :edit]
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: MyappWeb.Telemetry
    end
  end
end
