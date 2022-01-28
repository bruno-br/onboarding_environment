defmodule Mailer.Management.Email do
  import Bamboo.Email

  def report_email() do
    new_email(
      from: "from@mail.com",
      to: "to@mail.com",
      subject: "Report",
      text_body: "Report text body",
      html_body: "Report html body"
    )
  end

end
