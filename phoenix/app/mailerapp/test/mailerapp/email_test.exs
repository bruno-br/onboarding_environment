defmodule MailerApp.EmailTest do
  use MailerApp.DataCase, async: false

  alias MailerApp.Email

  import Mock

  @email_params %{from: "from", html_body: "html_body", subject: "subject", text_body: "text_body", to: "to"}

  describe "create/1" do
   test_with_mock("calls Bamboo.Email new_email function", %{}, Bamboo.Email, [],
     new_email: fn @email_params -> "valid_email" end
   ) do
    Email.create(@email_params)
    assert_called(Bamboo.Email.new_email(@email_params))
   end
  end

end
