defmodule MyappWeb.ProductPlug do
  import Plug.Conn

  alias Myapp.Management

  def get_product(conn, _opt), do: find_by_id(conn, conn.params["id"])

  defp find_by_id(conn, nil), do: assign(conn, :get_product, {:error, :bad_request})

  defp find_by_id(conn, id) do
    with product <- Management.get_product!(id),
         true <- product != nil do
      assign(conn, :get_product, {:ok, product})
    else
      _ -> assign(conn, :get_product, {:error, :not_found})
    end
  end
end
