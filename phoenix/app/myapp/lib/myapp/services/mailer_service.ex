defmodule Myapp.Services.MailerService do

  def send_email() do
    url = "localhost:4444/send_email"
    headers = [{"Content-type", "application/json"}]
    body = %{
      from: "hattie.block86@ethereal.email",
      to: "ascrvf7j5vfyc46y@ethereal.email",
      subject: "Report 4",
      text_body: "Report text body",
      html_body: "Report html body"
    }

    encoded_body = encode_body(body)

    HTTPoison.post(url, encoded_body, headers, [])
  end

  defp encode_body(%{} = map), do: "{ #{format_keys_and_values(map)} }"

  defp format_keys_and_values(%{} = map), do: Enum.map_join(map, ", ", fn {key, val} -> ~s{"#{key}": "#{val}"} end)

end
