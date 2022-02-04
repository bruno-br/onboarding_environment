defmodule Myapp.Services.ReportsMailerService do
  alias Myapp.Services.MailerService

  def send_email(report_data, report_title) do
    body = %{
      from: "hattie.block86@ethereal.email",
      to: "ascrvf7j5vfyc46y@ethereal.email",
      subject: "Report Mail",
      text_body: "This Email contains a Report",
      html_body: "This Email contains a Report",
      attachment: %{
        content_type: "text/csv",
        filename: "#{report_title}.csv",
        data: report_data
      }
    }
    MailerService.send_email(body)
  end
end
