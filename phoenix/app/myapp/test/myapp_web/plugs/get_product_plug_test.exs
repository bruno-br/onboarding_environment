defmodule MyappWeb.Plugs.GetProductPlugTest do
  use MyappWeb.ConnCase

  alias Myapp.ManagementTest
  alias MyappWeb.Plugs.GetProductPlug

  describe "get product" do
    test "assigns product to conn when id is valid", %{conn: conn} do
      product = create_product()

      conn = get(conn, Routes.product_path(conn, :show, product.id))
      GetProductPlug.get_product(conn)

      assert conn.assigns[:get_product] == {:ok, product}
    end
  end

  defp create_product() do
    ManagementTest.product_fixture()
  end
end
