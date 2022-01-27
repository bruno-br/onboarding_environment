defmodule MailerWeb.SendEmailController do
  use MailerWeb, :controller
  use Plug.ErrorHandler

  alias Mailer.Services.SendEmailService

  def index(conn, _params) do
    case SendEmailService.send("email_data") do
      {:ok, message}  -> send_resp(conn, :ok, message)
      _ -> send_resp(conn, :internal_server_error, "There was an error trying to send the email")
    end
  end
end
