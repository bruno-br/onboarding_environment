defmodule MailerAppWeb.SendEmailController do
  use MailerAppWeb, :controller
  use Plug.ErrorHandler

  alias MailerApp.Services.SendEmailService

  def handle(conn, _params) do
    case SendEmailService.send("email_data") do
      {:ok, message}  -> send_resp(conn, :ok, message)
      _ -> send_resp(conn, :internal_server_error, "There was an error trying to send the email")
    end
  end
end
