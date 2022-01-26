defmodule MailerWeb.SendEmailController do
  use MailerWeb, :controller
  use Plug.ErrorHandler

  def index(conn, _params) do
    send_resp(conn, :no_content, "")
  end
end
