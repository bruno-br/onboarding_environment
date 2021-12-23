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
    get_product(conn)
  end

  def get_product(conn), do: find_by_id(conn, conn.params["id"])

  defp find_by_id(conn, nil), do: assign(conn, :get_product, {:error, :bad_request})

  defp find_by_id(conn, id) do
    with product <- Management.get_product(id),
         true <- product != nil do
      assign(conn, :get_product, {:ok, product})
    else
      _ -> assign(conn, :get_product, {:error, :not_found})
    end
  end
end
