defmodule MyappWeb.ProductControllerTest do
  use MyappWeb.ConnCase, async: false

  alias Myapp.Management
  alias Myapp.Management.Product
  alias Myapp.Repo

  import Mock

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
      assert products = json_response(conn, 200)["products"]

      expected_ids = products_map_id(list_products())
      assert products_map_id(products) == expected_ids
    end

    test_with_mock "creates new log when action is on index", %{conn: conn}, Tirexs.HTTP, [],
      post: fn "/my_index/logs", data -> data end do
      conn = get(conn, Routes.product_path(conn, :index))
      assert json_response(conn, 200)

      assert_called(
        Tirexs.HTTP.post(
          "/my_index/logs",
          :meck.is(fn log ->
            assert log[:date] != nil
            assert log[:method] == conn.method
            assert log[:request_path] == conn.request_path
            assert log[:req_headers] == conn.req_headers
            assert log[:body_params] == conn.body_params
          end)
        )
      )
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn, valid_attrs: attrs} do
      conn = post(conn, Routes.product_path(conn, :create), product: attrs)
      assert %{"product" => product} = json_response(conn, 201)
      assert Repo.get(Product, product["id"]) != nil
    end

    test_with_mock "creates new log when action is on create",
                   %{conn: conn, valid_attrs: attrs},
                   Tirexs.HTTP,
                   [],
                   post: fn _path, data -> data end do
      conn = post(conn, Routes.product_path(conn, :create), product: attrs)
      assert json_response(conn, 201)

      assert_called(
        Tirexs.HTTP.post(
          "/my_index/logs",
          :meck.is(fn log ->
            assert log[:date] != nil
            assert log[:method] == conn.method
            assert log[:request_path] == conn.request_path
            assert log[:req_headers] == conn.req_headers
            assert log[:body_params] == conn.body_params
          end)
        )
      )
    end

    test "returns errors when data is invalid", %{conn: conn, invalid_attrs: attrs} do
      conn = post(conn, Routes.product_path(conn, :create), product: attrs)

      expected_response = %{
        "amount" => ["can't be blank"],
        "barcode" => ["can't be blank"],
        "description" => ["can't be blank"],
        "name" => ["can't be blank"],
        "price" => ["can't be blank"],
        "sku" => ["can't be blank"]
      }

      assert json_response(conn, 422)["errors"] == expected_response
    end

    test "returns error message when sku is invalid", %{conn: conn, valid_attrs: attrs} do
      product = %{attrs | sku: "invalid sku !!"}
      conn = post(conn, Routes.product_path(conn, :create), product: product)

      expected_response = %{
        "sku" => ["can only contain alphanumerics and hifen"]
      }

      assert json_response(conn, 422)["errors"] == expected_response
    end

    test "returns error when name is missing", %{conn: conn, valid_attrs: attrs} do
      product = Map.delete(attrs, :name)
      conn = post(conn, Routes.product_path(conn, :create), product: product)

      expected_response = %{"name" => ["can't be blank"]}

      assert json_response(conn, 422)["errors"] == expected_response
    end

    test "returns error when price is not greater than zero", %{conn: conn, valid_attrs: attrs} do
      product = %{attrs | price: 0}
      conn = post(conn, Routes.product_path(conn, :create), product: product)

      expected_response = %{"price" => ["must be greater than 0"]}

      assert json_response(conn, 422)["errors"] == expected_response
    end

    test "returns error when barcode has less than 8 digits", %{conn: conn, valid_attrs: attrs} do
      product = %{attrs | barcode: "1234567"}
      conn = post(conn, Routes.product_path(conn, :create), product: product)

      expected_response = %{
        "barcode" => ["should be at least 8 character(s)"]
      }

      assert json_response(conn, 422)["errors"] == expected_response
    end

    test "returns error when barcode has more than 13 digits", %{conn: conn, valid_attrs: attrs} do
      product = %{attrs | barcode: "12345678901234"}
      conn = post(conn, Routes.product_path(conn, :create), product: product)

      expected_response = %{
        "barcode" => ["should be at most 13 character(s)"]
      }

      assert json_response(conn, 422)["errors"] == expected_response
    end
  end

  describe "show product" do
    setup [:create_product]

    test "renders product when id is valid", %{conn: conn, product: %Product{id: id}} do
      conn = get(conn, Routes.product_path(conn, :show, id))

      expected_response = %{
        "id" => id,
        "amount" => 42,
        "description" => "some description",
        "name" => "some name",
        "price" => 120.5,
        "sku" => "some-sku",
        "barcode" => "123456789"
      }

      assert json_response(conn, 200)["product"] == expected_response
    end

    test_with_mock "creates new log when action is on show",
                   %{conn: conn, product: %Product{id: id}},
                   Tirexs.HTTP,
                   [],
                   post: fn "/my_index/logs", data -> data end do
      conn = get(conn, Routes.product_path(conn, :show, id))
      assert json_response(conn, 200)

      assert_called(
        Tirexs.HTTP.post(
          "/my_index/logs",
          :meck.is(fn log ->
            assert log[:date] != nil
            assert log[:method] == conn.method
            assert log[:request_path] == conn.request_path
            assert log[:req_headers] == conn.req_headers
            assert log[:body_params] == conn.body_params
          end)
        )
      )
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

      updated_product = Repo.get(Product, id)

      assert updated_product.id == id
      assert updated_product.amount == attrs.amount
      assert updated_product.description == attrs.description
      assert updated_product.name == attrs.name
      assert updated_product.price == attrs.price
      assert updated_product.sku == attrs.sku
      assert updated_product.barcode == attrs.barcode
    end

    test_with_mock "creates new log when action is on update",
                   %{
                     conn: conn,
                     product: product,
                     update_attrs: attrs
                   },
                   Tirexs.HTTP,
                   [],
                   post: fn "/my_index/logs", data -> data end do
      conn = put(conn, Routes.product_path(conn, :update, product), product: attrs)
      assert json_response(conn, 200)

      assert_called(
        Tirexs.HTTP.post(
          "/my_index/logs",
          :meck.is(fn log ->
            assert log[:date] != nil
            assert log[:method] == conn.method
            assert log[:request_path] == conn.request_path
            assert log[:req_headers] == conn.req_headers
            assert log[:body_params] == conn.body_params
          end)
        )
      )
    end

    test "returns errors when data is invalid", %{
      conn: conn,
      product: product,
      invalid_attrs: attrs
    } do
      conn = put(conn, Routes.product_path(conn, :update, product), product: attrs)

      expected_response = %{
        "amount" => ["can't be blank"],
        "barcode" => ["can't be blank"],
        "description" => ["can't be blank"],
        "name" => ["can't be blank"],
        "price" => ["can't be blank"],
        "sku" => ["can't be blank"]
      }

      assert json_response(conn, 422)["errors"] == expected_response
    end

    test "returns 404 if product is not found", %{conn: conn, update_attrs: attrs} do
      conn = put(conn, Routes.product_path(conn, :update, "invalid_product_id"), product: attrs)

      assert response(conn, 404)
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      assert Repo.get(Product, product.id) == product

      conn = delete(conn, Routes.product_path(conn, :delete, product))
      assert response(conn, 204)

      assert Repo.get(Product, product.id) == nil
    end

    test_with_mock "creates new log when action is on delete",
                   %{conn: conn, product: product},
                   Tirexs.HTTP,
                   [],
                   post: fn "/my_index/logs", data -> data end do
      conn = delete(conn, Routes.product_path(conn, :delete, product))
      assert response(conn, 204)

      assert_called(
        Tirexs.HTTP.post(
          "/my_index/logs",
          :meck.is(fn log ->
            assert log[:date] != nil
            assert log[:method] == conn.method
            assert log[:request_path] == conn.request_path
            assert log[:req_headers] == conn.req_headers
            assert log[:body_params] == conn.body_params
          end)
        )
      )
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

  defp products_map_id(products) do
    Enum.map(products, fn
      %{"id" => id} = _product -> id
      %{id: id} = _product -> id
    end)
  end
end
