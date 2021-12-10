defmodule MyappWeb.ProductPlug do
  import Plug.Conn

  alias Myapp.Management

  def get_product(conn, _opt) do
    with true <- conn.params["id"] != nil,
         product <- Management.get_product!(conn.params["id"]),
         true <- product != nil do
      assign(conn, :get_product, {:ok, product})
    else
      _ -> assign(conn, :get_product, {:error, :not_found})
    end
  end
end
