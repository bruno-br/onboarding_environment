defmodule MailerAppWeb.SendEmailController do
  use MailerAppWeb, :controller
  use Plug.ErrorHandler

  alias MailerApp.Services.SendEmailService

  def handle(conn, params) do
    case SendEmailService.send(params) do
      {:ok, message} -> send_resp(conn, :ok, message)
      {:error, reason} -> send_resp(conn, :internal_server_error, reason)
    end
  end
end
