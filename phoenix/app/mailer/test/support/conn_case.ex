defmodule MailerWeb.ConnCase do

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MailerWeb.ConnCase

      alias MailerWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint MailerWeb.Endpoint
    end
  end

  setup tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
