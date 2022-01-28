defmodule MailerApp.Services.SendEmailService do

  alias MailerApp.{Email, Mailer}

  def send(data) do
    Email.report_email() |> Mailer.deliver_later()
    {:ok, "Email sent successfully"}
  end
end
