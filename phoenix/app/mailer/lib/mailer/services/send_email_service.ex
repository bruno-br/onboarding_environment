defmodule Mailer.Services.SendEmailService do

  alias Mailer.Management.Email
  alias Mailer.Mailer

  def send(data) do
    Email.report_email() |> Mailer.deliver_now()
    {:ok, "Email sent successfully"}
  end
end
