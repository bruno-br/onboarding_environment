defmodule MailerWeb.SendEmailControllerTest do
  use MailerWeb.ConnCase, async: false

  alias Mailer.Services.SendEmailService

  import Mock

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index/1" do
    test_with_mock("returns 200 status code", %{conn: conn}, SendEmailService, [],
      send: fn _data -> {:ok, "message"} end
    ) do
      conn = get(conn, Routes.send_email_path(conn, :index))
      response(conn, 200)
    end
  end
end
