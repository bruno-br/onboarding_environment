defmodule MyappWeb.ProductControllerTest do
  use MyappWeb.ConnCase

  alias Myapp.Management
  alias Myapp.Management.Product

  @valid_attrs %{
    amount: 42,
    description: "some description",
    name: "some name",
    price: 120.5,
    sku: "some-sku",
    barcode: "123456789"
  }
  @update_attrs %{
    amount: 43,
    description: "some updated description",
    name: "some updated name",
    price: 456.7,
    sku: "some-updated-sku",
    barcode: "123456789"
  }
  @invalid_attrs %{amount: nil, description: nil, name: nil, price: nil, sku: nil, barcode: nil}

  def fixture(:product) do
    {:ok, product} = Management.create_product(@valid_attrs)
    product
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
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, Routes.product_path(conn, :create), product: @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)["product"]

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

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.product_path(conn, :create), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns error when sku is invalid", %{conn: conn} do
      product = %{@valid_attrs | sku: "invalid sku !!"}
      conn = post(conn, Routes.product_path(conn, :create), product: product)
      assert json_response(conn, 422)
    end

    test "returns error when name is missing", %{conn: conn} do
      product = Map.delete(@valid_attrs, :name)
      conn = post(conn, Routes.product_path(conn, :create), product: product)
      assert json_response(conn, 422)
    end

    test "returns error when price is not greater than zero", %{conn: conn} do
      product = %{@valid_attrs | price: 0}
      conn = post(conn, Routes.product_path(conn, :create), product: product)
      assert json_response(conn, 422)
    end

    test "returns error when barcode has less than 8 digits", %{conn: conn} do
      product = %{@valid_attrs | barcode: "1234567"}
      conn = post(conn, Routes.product_path(conn, :create), product: product)
      assert json_response(conn, 422)
    end

    test "returns error when barcode has more than 13 digits", %{conn: conn} do
      product = %{@valid_attrs | barcode: "12345678901234"}
      conn = post(conn, Routes.product_path(conn, :create), product: product)
      assert json_response(conn, 422)
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, Routes.product_path(conn, :update, product), product: @update_attrs)
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

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, Routes.product_path(conn, :update, product), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 404 if product is not found", %{conn: conn} do
      conn =
        put(conn, Routes.product_path(conn, :update, "invalid_product_id"), product: @update_attrs)

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

  defp create_product(_) do
    product = fixture(:product)
    %{product: product}
  end

  defp list_products() do
    Management.list_products()
  end
end
