defmodule MailerAppWeb.Router do
  use MailerAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MailerAppWeb do
    pipe_through :api
    post("/send_email", SendEmailController, :handle)
  end
end
