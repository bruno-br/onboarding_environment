defmodule MyappWeb.Plugs.GetProductPlugTest do
  use MyappWeb.ConnCase

  alias Myapp.Management
  alias MyappWeb.Plugs.GetProductPlug

  import Mock

  describe "get product" do
    test "assigns product to conn when id is valid", %{conn: conn} do
      product = "product"

      with_mock(Management,
        get_product: fn id -> product end
      ) do
        conn =
          %{conn | params: %{"id" => "existing_id"}}
          |> GetProductPlug.call("opts")

        assert conn.assigns[:get_product] == {:ok, product}
      end
    end

    test "assigns not_found error when id is not found", %{conn: conn} do
      conn =
        %{conn | params: %{"id" => "non_existing_id"}}
        |> GetProductPlug.call("opts")

      assert conn.assigns[:get_product] == {:error, :not_found}
    end
  end
end
