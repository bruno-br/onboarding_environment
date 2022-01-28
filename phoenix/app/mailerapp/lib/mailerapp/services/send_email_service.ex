defmodule MailerApp.Services.SendEmailService do

  alias MailerApp.Management.Email
  alias MailerApp.Mailer

  def send(data) do
    Email.report_email() |> Mailer.deliver_now()
    {:ok, "Email sent successfully"}
  end
end
