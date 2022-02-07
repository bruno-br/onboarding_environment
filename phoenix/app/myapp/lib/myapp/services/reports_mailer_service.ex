defmodule Myapp.Services.ReportsMailerService do
  alias Myapp.Services.MailerService

  def send_email(
        title,
        %{content_type: _content_type, filename: _filename, data: data} = attachment
      ) do
    encoded_data = Base.encode16(data)
    attachment = %{attachment | data: encoded_data}

    body = %{
      from: "hattie.block86@ethereal.email",
      to: "ascrvf7j5vfyc46y@ethereal.email",
      subject: "The report \"#{title}\" was generated",
      text_body: "This Email contains a Report",
      html_body: "<h1>This Email contains a Report</h1>",
      attachment: attachment
    }

    MailerService.send_email(body)
  end
end
