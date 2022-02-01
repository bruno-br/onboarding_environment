defmodule MailerApp.Services.SendEmailService do
  alias MailerApp.{Email, Mailer}

  def send(%{from: from, html_body: html_body, subject: subject, text_body: text_body, to: to} = email_params) do
    Email.create(email_params) |> Mailer.deliver_later()
    {:ok, "Email sent successfully"}
  end
end
