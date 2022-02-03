defmodule Myapp.Services.MailerService do
  def send_email(body) do
    url = get_send_email_url()
    headers = get_default_headers()
    encoded_body = encode_body(body)

    HTTPoison.post(url, encoded_body, headers, [])
  end

  defp get_mailer_base_url(), do: Application.get_env(:myapp, MailerApi)[:url]

  defp get_send_email_url(), do: get_mailer_base_url() <> "/send_email"

  defp get_default_headers(), do: [{"Content-type", "application/json"}]

  defp encode_body(%{} = map), do: "{ #{format_keys_and_values(map)} }"

  defp format_keys_and_values(%{} = map),
    do: Enum.map_join(map, ", ", fn {key, val} -> ~s{"#{key}": "#{val}"} end)
end
