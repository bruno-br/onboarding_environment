defmodule MailerAppWeb.SendEmailControllerTest do
  use MailerAppWeb.ConnCase, async: false

  alias MailerApp.Services.SendEmailService

  import Mock

  setup %{conn: conn} do
    [
      conn: put_req_header(conn, "accept", "application/json"),
      send_email_params: %{"from" => "from@mail.com", "to" => "to@mail.com"},
      send_email_error_response: {:error, "There was an error trying to send the email"},
      send_email_success_response: {:accepted, "The Email is going to be sent"}
    ]
  end

  describe "handle/2" do
    test_with_mock(
      "returns error message if there is an error on SendEmailService.send",
      %{conn: conn, send_email_error_response: send_email_error_response},
      SendEmailService,
      [],
      send: fn _data -> send_email_error_response end
    ) do
      conn = post(conn, Routes.send_email_path(conn, :handle))

      {:error, expected_response} = send_email_error_response

      assert response(conn, 500) == expected_response
    end
  end

  test_with_mock(
    "send correct params to SendEmailService.send and return success response",
    %{
      conn: conn,
      send_email_params: send_email_params,
      send_email_success_response: send_email_success_response
    },
    SendEmailService,
    [],
    send: fn _data -> send_email_success_response end
  ) do
    conn = post(conn, Routes.send_email_path(conn, :handle), send_email_params)

    assert_called(SendEmailService.send(send_email_params))

    {:accepted, expected_response} = send_email_success_response

    assert response(conn, 202) == expected_response
  end
end
