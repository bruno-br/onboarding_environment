defmodule Myapp.Services.ReportsMailerService do
  alias Myapp.Services.MailerService

  def send_email(title, %{content_type: _content_type, filename: _filename, data: _data} = attachment) do
    body = %{
      from: "hattie.block86@ethereal.email",
      to: "ascrvf7j5vfyc46y@ethereal.email",
      subject: title,
      text_body: "This Email contains a Report",
      html_body: "This Email contains a Report",
      attachment: attachment
    }
    MailerService.send_email(body)
  end
end
