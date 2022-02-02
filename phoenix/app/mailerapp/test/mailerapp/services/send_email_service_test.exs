defmodule MailerApp.Services.SendEmailServiceTest do
  use MailerApp.DataCase, async: false

  alias MailerApp.{Email, Mailer}
  alias MailerApp.Services.SendEmailService

  import Mock

  @email_params_atom %{key: "value"}
  @email_params_string %{"key" => "value"}
  @valid_email "email"

  setup_with_mocks([
    {Email, [],
     create: fn
       @email_params_atom -> @valid_email
       _invalid_params -> :error
     end},
    {Mailer, [], deliver_later: fn @valid_email -> :ok end}
  ]) do
    :ok
  end

  describe "send/1" do
    test "returns success message if there were no errors" do
      expected_response = {:accepted, "The Email is going to be sent"}
      assert SendEmailService.send(@email_params_string) == expected_response
    end

    test "returns error message if there is an error" do
      expected_response = {:error, "There was an error trying to send the email"}
      assert SendEmailService.send(@email_params_atom) == expected_response
    end

    test "calls Email.create/1 and Mailer.deliver_later/1 with correct params" do
      SendEmailService.send(@email_params_string)
      assert_called(Email.create(@email_params_atom))
      assert_called(Mailer.deliver_later(@valid_email))
    end
  end
end
