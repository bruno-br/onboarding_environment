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
  @request_body_encoded "request_body_encoded"

  @response_body_success "The email is going to be sent"
  @response_body_failed "There was an error trying to send the email"
  @response_accepted {:ok, %HTTPoison.Response{body: @response_body_success, status_code: 202}}
  @response_error {:ok, %HTTPoison.Response{body: @response_body_failed, status_code: 500}}

  setup_with_mocks([
    {HTTPoison, [],
     post: fn
       _url, @request_body_encoded, _headers, _opts -> @response_accepted
       _url, _body, _headers, _opts -> @response_error
     end},
    {Poison, [],
     encode: fn
       @request_body -> {:ok, @request_body_encoded}
       _value -> {:ok, "encoded_value"}
     end}
  ]) do
    :ok
  end

  describe "send_email/1" do
    test "return success message when response status code is 202" do
      expected_response = {:ok, @response_body_success}
      assert MailerService.send_email(@request_body) == expected_response
    end

    test "calls HTTPoison.post/4 function" do
      MailerService.send_email(@request_body)
      assert_called(HTTPoison.post(:_, :_, :_, []))
    end

    test "returns error message when response status code is different from 202" do
      expected_response = {:error, @response_body_failed}
      assert MailerService.send_email(%{}) == expected_response
    end
  end
end
