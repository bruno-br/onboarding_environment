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
  @attachment %{content_type: "text/csv", filename: "file.csv", data: "data"}
  @valid_email "valid_email"

  setup_with_mocks([
    {
      Bamboo.Email,
      [],
      new_email: fn @email_params -> @valid_email end,
      put_attachment: fn _email, _attachment -> @valid_email end
    },{Base, decode16, fn _encoded_data -> "data"}
  ]) do
    :ok
  end

  describe "create/1" do
    test("returns valid_email on success") do
      assert Email.create(@email_params) == @valid_email
    end

    test("calls Bamboo.Email.new_email/1 function") do
      Email.create(@email_params)
      assert_called(Bamboo.Email.new_email(@email_params))
    end

    test("calls Bamboo.Email.put_attachment/2 when params contains attachment") do
      email_params_with_attachment = Map.merge(@email_params, %{attachment: @attachment})
      Email.create(email_params_with_attachment)
      assert_called(Bamboo.Email.put_attachment(@valid_email, :_))
    end

    test("does not call Bamboo.Email.put_attachment/2 when params does not contain attachment") do
      Email.create(@email_params)
      assert_not_called(Bamboo.Email.put_attachment(@valid_email, :_))
    end

    test("decodes attachment data") do
      Email.create(@email_params)
      assert_called(Base.decode16(@attachment[:data]))
    end
  end
end
