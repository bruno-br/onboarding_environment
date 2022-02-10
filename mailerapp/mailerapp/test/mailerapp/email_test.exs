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
  @attachment %{content_type: "text/csv", filename: "file.csv", data: "encoded_data"}
  @email_params_with_attachment Map.merge(@email_params, %{attachment: @attachment})
  @valid_email "valid_email"
  @decoded_data "decoded_data"

  setup_with_mocks([
    {
      Bamboo.Email,
      [],
      new_email: fn @email_params -> @valid_email end,
      put_attachment: fn _email, _attachment -> @valid_email end
    },
    {Base, [], decode16: fn _encoded_data -> {:ok, @decoded_data} end}
  ]) do
    :ok
  end

  describe "create/1" do
    test("returns valid_email on success") do
      assert Email.create(@email_params) == @valid_email
      assert_called(Bamboo.Email.new_email(@email_params))
      assert_not_called(Bamboo.Email.put_attachment(@valid_email, :_))
    end

    test("calls Bamboo.Email.put_attachment/2 when an attachment is sent on params") do
      Email.create(@email_params_with_attachment)

      bamboo_attachment = %Bamboo.Attachment{
        content_type: @attachment[:content_type],
        filename: @attachment[:filename],
        data: @decoded_data
      }

      assert_called(Bamboo.Email.put_attachment(@valid_email, bamboo_attachment))
    end

    test("decodes attachment data") do
      Email.create(@email_params_with_attachment)
      assert_called(Base.decode16(@attachment[:data]))
    end
  end
end
