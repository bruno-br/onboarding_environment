defmodule MyappWeb.ProductControllerTest do
  use MyappWeb.ConnCase

  alias Myapp.Management
  alias Myapp.Management.Product

  setup_all do
    %{
      valid_attrs: %{
        amount: 42,
        description: "some description",
        name: "some name",
        price: 120.5,
        sku: "some-sku",
        barcode: "123456789"
      },
      update_attrs: %{
        amount: 43,
        description: "some updated description",
        name: "some updated name",
        price: 456.7,
        sku: "some-updated-sku",
        barcode: "123456789"
      },
      invalid_attrs: %{
        amount: nil,
        description: nil,
        name: nil,
        price: nil,
        sku: nil,
        barcode: nil
      }
    }
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, Routes.product_path(conn, :index))
      assert length(json_response(conn, 200)["products"]) == length(list_products())
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn, valid_attrs: attrs} do
      conn = post(conn, Routes.product_path(conn, :create), product: attrs)
      assert %{"product" => product} = json_response(conn, 201)

      conn = get(conn, Routes.product_path(conn, :show, product["id"]))
      assert json_response(conn, 200)["product"] == product
    end

    test "returns errors when data is invalid", %{conn: conn, invalid_attrs: attrs} do
      conn = post(conn, Routes.product_path(conn, :create), product: attrs)

      assert json_response(conn, 422)["errors"] == %{
               "amount" => ["can't be blank"],
               "barcode" => ["can't be blank"],
               "description" => ["can't be blank"],
               "name" => ["can't be blank"],
               "price" => ["can't be blank"],
               "sku" => ["can't be blank"]
             }
    end

    test "returns error message when sku is invalid", %{conn: conn, valid_attrs: attrs} do
      product = %{attrs | sku: "invalid sku !!"}
      conn = post(conn, Routes.product_path(conn, :create), product: product)

      assert json_response(conn, 422)["errors"] == %{
               "sku" => ["can only contain alphanumerics and hifen"]
             }
    end

    test "returns error when name is missing", %{conn: conn, valid_attrs: attrs} do
      product = Map.delete(attrs, :name)
      conn = post(conn, Routes.product_path(conn, :create), product: product)
      assert json_response(conn, 422)["errors"] == %{"name" => ["can't be blank"]}
    end

    test "returns error when price is not greater than zero", %{conn: conn, valid_attrs: attrs} do
      product = %{attrs | price: 0}
      conn = post(conn, Routes.product_path(conn, :create), product: product)
      assert json_response(conn, 422)["errors"] == %{"price" => ["must be greater than 0"]}
    end

    test "returns error when barcode has less than 8 digits", %{conn: conn, valid_attrs: attrs} do
      product = %{attrs | barcode: "1234567"}
      conn = post(conn, Routes.product_path(conn, :create), product: product)

      assert json_response(conn, 422)["errors"] == %{
               "barcode" => ["should be at least 8 character(s)"]
             }
    end

    test "returns error when barcode has more than 13 digits", %{conn: conn, valid_attrs: attrs} do
      product = %{attrs | barcode: "12345678901234"}
      conn = post(conn, Routes.product_path(conn, :create), product: product)

      assert json_response(conn, 422)["errors"] == %{
               "barcode" => ["should be at most 13 character(s)"]
             }
    end
  end

  describe "show product" do
    setup [:create_product]

    test "renders product when id is valid", %{conn: conn, product: %Product{id: id}} do
      conn = get(conn, Routes.product_path(conn, :show, id))

      assert %{
               "id" => id,
               "amount" => 42,
               "description" => "some description",
               "name" => "some name",
               "price" => 120.5,
               "sku" => "some-sku",
               "barcode" => "123456789"
             } = json_response(conn, 200)["product"]
    end

    test "returns 404 if product is not found", %{conn: conn} do
      conn = get(conn, Routes.product_path(conn, :show, "invalid_id"))
      assert response(conn, 404)
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{
      conn: conn,
      product: %Product{id: id} = product,
      update_attrs: attrs
    } do
      conn = put(conn, Routes.product_path(conn, :update, product), product: attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["product"]

      conn = get(conn, Routes.product_path(conn, :show, id))

      assert %{
               "id" => id,
               "amount" => 43,
               "description" => "some updated description",
               "name" => "some updated name",
               "price" => 456.7,
               "sku" => "some-updated-sku",
               "barcode" => "123456789"
             } = json_response(conn, 200)["product"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      product: product,
      invalid_attrs: attrs
    } do
      conn = put(conn, Routes.product_path(conn, :update, product), product: attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 404 if product is not found", %{conn: conn, update_attrs: attrs} do
      conn = put(conn, Routes.product_path(conn, :update, "invalid_product_id"), product: attrs)

      assert response(conn, 404)
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, Routes.product_path(conn, :delete, product))
      assert response(conn, 204)
    end

    test "returns 404 if product is not found", %{conn: conn} do
      conn = delete(conn, Routes.product_path(conn, :delete, "invalid_product_id"))
      assert response(conn, 404)
    end
  end

  defp fixture(:product) do
    {:ok, product} =
      Management.create_product(%{
        amount: 42,
        description: "some description",
        name: "some name",
        price: 120.5,
        sku: "some-sku",
        barcode: "123456789"
      })

    product
  end

  defp create_product(_) do
    product = fixture(:product)
    %{product: product}
  end

  defp list_products() do
    Management.list_products()
  end
end
