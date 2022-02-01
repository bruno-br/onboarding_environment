defmodule MailerApp.Services.SendEmailService do
  alias MailerApp.{Email, Mailer}

  def send(email_params) do
    email_params
    |> map_string_keys_to_atoms()
    |> Email.create()
    |> Mailer.deliver_later()
    {:ok, "Email sent successfully"}
  end

  defp map_string_keys_to_atoms(map_string_keys), do: for {key, val} <- map_string_keys, into: %{}, do: {String.to_existing_atom(key), val}
end
