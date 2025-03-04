defmodule MyappWeb.Plugs.GetProductPlug do
  @moduledoc """
  Plug used to get a product before the
  action goes to the controller
  """

  import Plug.Conn

  alias Myapp.Management

  def init(props) do
    props
  end

  def call(conn, _opts) do
    find_product_by_id(conn, conn.params["id"])
  end

  defp find_product_by_id(conn, nil) do
    conn
    |> halt()
    |> send_resp(:bad_request, "")
  end

  defp find_product_by_id(conn, id) do
    case Management.get_product(id) do
      nil ->
        conn
        |> halt()
        |> send_resp(:not_found, "")

      product ->
        assign(conn, :product, product)
    end
  end
end
