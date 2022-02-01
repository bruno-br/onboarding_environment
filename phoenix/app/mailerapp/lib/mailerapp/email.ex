defmodule MailerApp.Email do
  import Bamboo.Email

  def create(%{from: from, html_body: html_body, subject: subject, text_body: text_body, to: to} = email_params) do
    new_email(email_params)
  end

end
