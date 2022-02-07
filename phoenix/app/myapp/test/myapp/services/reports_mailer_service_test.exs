defmodule Myapp.Services.ReportsMailerServiceTest do
  use Myapp.DataCase, async: false

  alias Myapp.Services.{ReportsMailerService, MailerService}

  import Mock

  @attachment %{content_type: "text/csv", filename: "report.csv", data: "data"}
  @success_response {:ok, "Email sent successfully"}

  setup_with_mocks([
    {MailerService, [],
     send_email: fn
       _body -> @success_response
     end},{Base, [], encode16: fn _data -> "encoded_data" end}
  ]) do
    :ok
  end

  describe "send_email/2" do
    test "calls MailerService.send_email/1" do
      ReportsMailerService.send_email("report title", @attachment)
      assert_called(MailerService.send_email(:_))
    end

    test "returns response from MailerService.send_email/1" do
      assert ReportsMailerService.send_email("report title", @attachment) == @success_response
    end

   test "encodes attachment data before sending" do
    ReportsMailerService.send_email("report title", @attachment)
    assert_called(Base.encode16(@attachment[:data]))
   end
  end
end
