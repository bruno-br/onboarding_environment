defmodule Myapp.Services.MailerServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.MailerService

  import Mock

  @request_body %{
    to: "to@mail.com",
    from: "from@mail.com",
    subject: "Email subject",
    text_body: "text body",
    html_body: "html body"
  }

  @response_body_success "The email is going to be sent"
  @response_accepted {:ok, %HTTPoison.Response{body: @response_body_success, status_code: 202}}

  describe "send_email/1" do
    test_with_mock("return success message when response status code is 202", HTTPoison, [],
      post: fn _url, _body, _headers, _opts -> @response_accepted end
    ) do
      expected_response = {:ok, @response_body_success}
      assert MailerService.send_email(%{}) == expected_response
    end
  end
end
