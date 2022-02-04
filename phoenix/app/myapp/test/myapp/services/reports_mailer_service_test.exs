defmodule Myapp.Services.ReportsMailerServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.{ReportsMailerService, MailerService}

  import Mock

  @success_response {:ok, "Email sent successfully"}

  setup_with_mocks([
    {MailerService, [],
     send_email: fn
       _body -> @success_response
     end}
  ]) do
    :ok
  end

  describe "send_email/2" do
    test "calls MailerService.send_email/1" do
      ReportsMailerService.send_email()
      assert_called(MailerService.send_email(:_))
    end

    test "returns response from MailerService.send_email/1" do
      assert ReportsMailerService.send_email() == @success_response
    end
  end
end
