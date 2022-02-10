defmodule Myapp.Services.MailerService do
  def send_email(body) do
    url = get_send_email_url()
    headers = get_default_headers()

    with {:ok, encoded_body} <- encode_body(body),
         {:ok, message} <- post_mail(url, encoded_body, headers) do
      {:ok, message}
    else
      error -> error
    end
  end

  defp post_mail(url, body, headers) do
    case HTTPoison.post(url, body, headers, []) do
      {:ok, %HTTPoison.Response{body: response_body, status_code: 202}} -> {:ok, response_body}
      {:ok, %HTTPoison.Response{body: response_body}} -> {:error, response_body}
      error -> error
    end
  end

  defp get_mailer_base_url(), do: Application.get_env(:myapp, MailerApi)[:url]

  defp get_send_email_url(), do: get_mailer_base_url() <> "/send_email"

  defp get_default_headers(), do: [{"Content-type", "application/json"}]

  defp encode_body(body), do: Poison.encode(body)
end
