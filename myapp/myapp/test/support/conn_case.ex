defmodule MyappWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MyappWeb.ConnCase

      alias MyappWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint MyappWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
