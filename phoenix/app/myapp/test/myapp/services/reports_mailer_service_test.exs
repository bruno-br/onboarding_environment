defmodule Myapp.Services.ReportsMailerServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.{ReportsMailerService, MailerService}

  import Mock

  setup_with_mocks([
    {MailerService, [],
     send_email: fn
       _body -> {:ok, "Email sent successfully"}
     end}
  ]) do
    :ok
  end

  describe "send_email/0" do
    test "calls MailerService.send_email/1" do
      ReportsMailerService.send_email()
      assert_called(MailerService.send_email(:_))
    end
  end
end
