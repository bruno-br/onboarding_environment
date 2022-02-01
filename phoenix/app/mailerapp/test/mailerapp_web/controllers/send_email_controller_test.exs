defmodule MailerAppWeb.SendEmailControllerTest do
  use MailerAppWeb.ConnCase, async: false

  alias MailerApp.Services.SendEmailService

  import Mock

  @send_email_params %{"from" => "from@mail.com", "to" => "to@mail.com"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "handle/2" do
    test_with_mock(
      "returns 200 status code if SendEmailService.send is successful",
      %{conn: conn},
      SendEmailService,
      [],
      send: fn _data -> {:ok, "message"} end
    ) do
      conn = post(conn, Routes.send_email_path(conn, :handle))
      response(conn, 200)
    end

    test_with_mock(
      "return 500 if there is an error on SendEmailService.send",
      %{conn: conn},
      SendEmailService,
      [],
      send: fn _data -> {:error, "any error"} end
    ) do
      conn = post(conn, Routes.send_email_path(conn, :handle))
      response(conn, 500)
    end
  end

  test_with_mock(
    "send correct params to SendEmailService.send",
    %{conn: conn},
    SendEmailService,
    [],
    send: fn _data -> {:ok, "message"} end
  ) do
    post(conn, Routes.send_email_path(conn, :handle), @send_email_params)
    assert_called(SendEmailService.send(@send_email_params))
  end
end
