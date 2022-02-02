defmodule MailerApp.Services.SendEmailService do
  alias MailerApp.{Email, Mailer}

  def send(email_params) do
    email_params
    |> map_string_keys_to_atoms()
    |> Email.create()
    |> Mailer.deliver_later()

    {:accepted, "The Email is going to be sent"}
  rescue
    _ -> {:error, "There was an error trying to send the email"}
  end

  defp map_string_keys_to_atoms(map_string_keys),
    do: for({key, val} <- map_string_keys, into: %{}, do: {String.to_existing_atom(key), val})
end
