defmodule MailerAppWeb.Router do
  use MailerAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  scope "/", MailerAppWeb do
    pipe_through :api
    resources("/send_email", SendEmailController, only: [:index])
  end
end
