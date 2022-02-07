defmodule Myapp.Services.MailerService do
  def send_email(body) do
    url = get_send_email_url()
    headers = get_default_headers()
    encoded_body = encode_body(body)

    case HTTPoison.post(url, encoded_body, headers, []) do
      {:ok, %HTTPoison.Response{body: response_body, status_code: 202}} -> {:ok, response_body}
      {:ok, %HTTPoison.Response{body: response_body}} -> {:error, response_body}
      error -> error
    end
  end

  defp get_mailer_base_url(), do: Application.get_env(:myapp, MailerApi)[:url]

  defp get_send_email_url(), do: get_mailer_base_url() <> "/send_email"

  defp get_default_headers(), do: [{"Content-type", "application/json"}]

  defp encode_body(%{} = map), do: format_keys_and_values(map)

  defp format_keys_and_values(%{} = map),
    do: "{" <> Enum.map_join(map, ", ", fn {key, val} -> "\"#{key}\": #{format_keys_and_values(val)}" end) <> "}"

  defp format_keys_and_values(not_a_map),
    do: "\"#{format_value(not_a_map)}\""

  defp format_value(value), do: String.replace(value, "\"", "\\\"")
end
