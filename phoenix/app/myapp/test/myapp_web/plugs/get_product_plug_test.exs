defmodule MyappWeb.Plugs.GetProductPlugTest do
  use MyappWeb.ConnCase

  alias Myapp.ManagementTest
  alias MyappWeb.Plugs.GetProductPlug

  describe "get product" do
    test "assigns product to conn when id is valid", %{conn: conn} do
      product = create_product()
      conn = get(conn, Routes.product_path(conn, :show, product.id))

      assert conn.assigns[:get_product] == {:ok, product}
    end

    test "assigns not_found error when id is not found", %{conn: conn} do
      conn =
        %{conn | params: %{"id" => "non_existing_id"}}
        |> GetProductPlug.call("opts")

      assert conn.assigns[:get_product] == {:error, :not_found}
    end
  end

  defp create_product() do
    ManagementTest.product_fixture()
  end
end
