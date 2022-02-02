defmodule MailerApp.EmailTest do
  use MailerApp.DataCase, async: false

  alias MailerApp.Email

  import Mock

  @email_params %{
    from: "from",
    html_body: "html_body",
    subject: "subject",
    text_body: "text_body",
    to: "to"
  }
  @valid_email "valid_email"

  setup_with_mocks([
    {
      Bamboo.Email,
      [],
      new_email: fn @email_params -> @valid_email end
    }
  ]) do
    :ok
  end

  describe "create/1" do
    test("returns valid_email on success") do
      assert Email.create(@email_params) == @valid_email
    end

    test("calls Bamboo.Email new_email function") do
      Email.create(@email_params)
      assert_called(Bamboo.Email.new_email(@email_params))
    end
  end
end
