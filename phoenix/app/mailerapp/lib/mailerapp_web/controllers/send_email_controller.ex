defmodule MailerAppWeb.SendEmailController do
  use MailerAppWeb, :controller
  use Plug.ErrorHandler

  alias MailerApp.Services.SendEmailService

  def handle(conn, params) do

    atom_params = for {key, val} <- params, into: %{}, do: {String.to_existing_atom(key), val}

    case SendEmailService.send(atom_params) do
      {:ok, message}  -> send_resp(conn, :ok, message)
      _ -> send_resp(conn, :internal_server_error, "There was an error trying to send the email")
    end
  end
end
