defmodule MailerAppWeb.SendEmailController do
  use MailerAppWeb, :controller
  use Plug.ErrorHandler

  alias MailerApp.Services.SendEmailService

  def handle(conn, params) do
    case SendEmailService.send(params) do
      {:accepted, message} -> send_resp(conn, :accepted, message)
      {:error, reason} -> send_resp(conn, :internal_server_error, reason)
    end
  end
end
