defmodule MyappWeb.ProductControllerTest do
  use MyappWeb.ConnCase

  alias Myapp.Management
  alias Myapp.Management.Product

  @create_attrs %{
    amount: 42,
    description: "some description",
    name: "some name",
    price: 120.5,
    sku: "some-sku"
  }
  @update_attrs %{
    amount: 43,
    description: "some updated description",
    name: "some updated name",
    price: 456.7,
    sku: "some-updated-sku"
  }
  @invalid_attrs %{amount: nil, description: nil, name: nil, price: nil, sku: nil}

  def fixture(:product) do
    {:ok, product} = Management.create_product(@create_attrs)
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
      conn = post(conn, Routes.product_path(conn, :create), product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["product"]

      conn = get(conn, Routes.product_path(conn, :show, id))

      assert %{
               "id" => id,
               "amount" => 42,
               "description" => "some description",
               "name" => "some name",
               "price" => 120.5,
               "sku" => "some-sku"
             } = json_response(conn, 200)["product"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.product_path(conn, :create), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
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
               "sku" => "some-updated-sku"
             } = json_response(conn, 200)["product"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, Routes.product_path(conn, :update, product), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, Routes.product_path(conn, :delete, product))
      assert response(conn, 204)
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
