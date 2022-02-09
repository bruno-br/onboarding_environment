defmodule MailerAppWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MailerAppWeb.ConnCase

      alias MailerAppWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint MailerAppWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
