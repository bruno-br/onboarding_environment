defmodule MailerAppWeb.SendEmailController do
  use MailerAppWeb, :controller
  use Plug.ErrorHandler

  alias MailerApp.Services.SendEmailService

  action_fallback(MailerAppWeb.FallbackController)

  def handle(conn, params), do: SendEmailService.send(params)
end
