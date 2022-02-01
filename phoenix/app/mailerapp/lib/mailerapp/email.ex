defmodule MailerApp.Email do
  import Bamboo.Email

  def create(
        %{from: _from, html_body: _html_body, subject: _subject, text_body: _text_body, to: _to} =
          email_params
      ) do
    new_email(email_params)
  end
end
