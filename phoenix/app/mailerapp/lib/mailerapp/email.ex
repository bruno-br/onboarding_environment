defmodule MailerApp.Email do
  import Bamboo.Email

  def create(%{
        from: from,
        html_body: html_body,
        subject: subject,
        text_body: text_body,
        to: to,
        attachment: %{content_type: content_type, filename: filename, data: data}
      }) do
    email =
      create(%{from: from, html_body: html_body, subject: subject, text_body: text_body, to: to})

    decoded_data = decode_attachment_data(data)

    put_attachment(email, %Bamboo.Attachment{
      content_type: content_type,
      filename: filename,
      data: decoded_data
    })
  end

  def create(
        %{from: _from, html_body: _html_body, subject: _subject, text_body: _text_body, to: _to} =
          email_params
      ) do
    new_email(email_params)
  end

  defp decode_attachment_data(data) do
    case Base.decode16(data) do
      {:ok, decoded_data} -> decoded_data
      _error -> data
    end
  end
end
