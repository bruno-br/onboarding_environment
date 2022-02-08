defmodule MailerAppWeb.FallbackController do
  use MailerAppWeb, :controller

  def call(conn, {:error, reason}),
    do: send_resp(conn, :internal_server_error, reason)

  def call(conn, {:accepted, message}),
    do: send_resp(conn, :accepted, message)
end
