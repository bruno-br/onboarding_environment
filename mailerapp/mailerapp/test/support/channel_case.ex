defmodule MailerAppWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ChannelTest
      import MailerAppWeb.ChannelCase

      # The default endpoint for testing
      @endpoint MailerAppWeb.Endpoint
    end
  end

  setup _tags do
    :ok
  end
end
