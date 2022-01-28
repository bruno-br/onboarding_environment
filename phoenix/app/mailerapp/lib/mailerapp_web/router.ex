defmodule MailerAppWeb.Router do
  use MailerAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MailerAppWeb do
    pipe_through :api
    resources("/send_email", SendEmailController, only: [:index])
  end
end
