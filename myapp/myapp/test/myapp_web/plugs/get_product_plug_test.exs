defmodule MyappWeb.Plugs.GetProductPlugTest do
  use MyappWeb.ConnCase, async: false

  import Mock

  alias Myapp.Management
  alias MyappWeb.Plugs.GetProductPlug

  setup_all do
    %{
      attrs: %{
        product: "valid_product",
        opts: "any_opts",
        id: "valid_id",
        invalid_id: "different id"
      }
    }
  end

  describe "get product" do
    test "assigns product to conn when id is valid", %{conn: conn, attrs: attrs} do
      with_mock(Management,
        get_product: fn _id -> attrs.product end
      ) do
        conn =
          %{conn | params: %{"id" => attrs.id}}
          |> GetProductPlug.call(attrs.opts)

        assert conn.assigns[:product] == attrs.product
      end
    end

    test "assigns not_found error when id is not found", %{conn: conn, attrs: attrs} do
      conn =
        %{conn | params: %{"id" => attrs.invalid_id}}
        |> GetProductPlug.call(attrs.opts)

      assert conn.assigns[:product] == nil
    end
  end
end
