defmodule Myapp.Services.ReportsMailerService do
  alias Myapp.Services.MailerService

  def send_email() do
    body = %{
      from: "hattie.block86@ethereal.email",
      to: "ascrvf7j5vfyc46y@ethereal.email",
      subject: "Report Mail",
      text_body: "This Email contains a Report",
      html_body: "This Email contains a Report"
    }
    MailerService.send_email(body)
  end
end
