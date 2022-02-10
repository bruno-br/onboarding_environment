defmodule MailerApp.EmailTest do
  use MailerApp.DataCase, async: false

  alias MailerApp.Email

  import Mock

  @valid_email "valid_email"
  @decoded_data "decoded_data"

  setup_all do
    %{
      email_params: %{
        from: "from",
        html_body: "html_body",
        subject: "subject",
        text_body: "text_body",
        to: "to"
      },
      email_params_with_attachment: %{
        from: "from",
        html_body: "html_body",
        subject: "subject",
        text_body: "text_body",
        to: "to",
        attachment: %{
          content_type: "text/csv",
          filename: "file.csv",
          data: "encoded_data"
        }
      }
    }
  end

  setup_with_mocks([
    {
      Bamboo.Email,
      [],
      new_email: fn _email_params -> @valid_email end,
      put_attachment: fn _email, _attachment -> @valid_email end
    },
    {Base, [], decode16: fn _encoded_data -> {:ok, @decoded_data} end}
  ]) do
    :ok
  end

  describe "create/1" do
    test("returns valid_email on success", %{email_params: email_params}) do
      assert Email.create(email_params) == @valid_email
      assert_called(Bamboo.Email.new_email(email_params))
      assert_not_called(Bamboo.Email.put_attachment(@valid_email, :_))
    end

    test("put attachment and decode its data when it is sent on params", %{
      email_params_with_attachment: email_params_with_attachment
    }) do
      Email.create(email_params_with_attachment)

      attachment = email_params_with_attachment[:attachment]

      bamboo_attachment = %Bamboo.Attachment{
        content_type: attachment[:content_type],
        filename: attachment[:filename],
        data: @decoded_data
      }

      assert_called(Bamboo.Email.put_attachment(@valid_email, bamboo_attachment))
      assert_called(Base.decode16(attachment[:data]))
    end
  end
end
