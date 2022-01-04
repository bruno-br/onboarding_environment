defmodule Myapp.ManagementTest do
  use Myapp.DataCase, async: false

  alias Myapp.Management

  alias Myapp.Management.Product
  alias Myapp.Services.ElasticsearchService

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

  describe "list_products/0" do
    setup [:create_product]
    setup [:clear_els]

    test "returns all products when elasticsearch returns list", %{product: product} do
      product_attrs = Product.get_attrs(product)

      with_mock ElasticsearchService,
        list: fn
          _path -> {:ok, [product_attrs]}
        end do
        assert Management.list_products() == [product_attrs]
      end
    end

    test "returns products from management when elasticsearchservice returns error", %{
      product: product
    } do
      with_mock ElasticsearchService,
        list: fn
          _path -> :error
        end do
        assert Management.list_products() == [Product.get_attrs(product)]
      end
    end
  end

  describe "get_product/1" do
    setup [:create_product]

    test "returns the product with given id", %{product: product} do
      assert Management.get_product(product.id) == product
    end

    test "returns nil when product is not found" do
      assert Management.get_product("invalid_id") == nil
    end
  end

  describe "create_product/1" do
    setup [:create_product]

    test "creates a product when data is valid", %{valid_attrs: attrs} do
      assert {:ok, %Product{} = product} = Management.create_product(attrs)
      assert product.amount == 42
      assert product.description == "some description"
      assert product.name == "some name"
      assert product.price == 120.5
      assert product.sku == "some-sku"
      assert product.barcode == "123456789"
    end

    test "returns error when data is invalid", %{invalid_attrs: attrs} do
      expected_errors = [
        sku: {"can't be blank", [validation: :required]},
        amount: {"can't be blank", [validation: :required]},
        description: {"can't be blank", [validation: :required]},
        name: {"can't be blank", [validation: :required]},
        price: {"can't be blank", [validation: :required]},
        barcode: {"can't be blank", [validation: :required]}
      ]

      assert {:error, response} = Management.create_product(attrs)
      assert response.errors == expected_errors
    end

    test "returns error when sku is invalid", %{valid_attrs: attrs} do
      product = %{attrs | sku: "invalid sku !!"}

      expected_errors = [
        sku: {"can only contain alphanumerics and hifen", [validation: :format]}
      ]

      assert {:error, response} = Management.create_product(product)
      assert response.errors == expected_errors
    end

    test "returns error when name is missing", %{valid_attrs: attrs} do
      product = Map.delete(attrs, :name)

      expected_errors = [name: {"can't be blank", [validation: :required]}]

      assert {:error, response} = Management.create_product(product)
      assert response.errors == expected_errors
    end

    test "returns error when price is not greater than zero", %{valid_attrs: attrs} do
      product = %{attrs | price: 0}

      expected_errors = [
        price:
          {"must be greater than %{number}",
           [validation: :number, kind: :greater_than, number: 0]}
      ]

      assert {:error, response} = Management.create_product(product)
      assert response.errors == expected_errors
    end

    test "returns error when barcode has less than 8 digits", %{valid_attrs: attrs} do
      product = %{attrs | barcode: "1234567"}

      expected_errors = [
        barcode:
          {"should be at least %{count} character(s)",
           [count: 8, validation: :length, kind: :min, type: :string]}
      ]

      assert {:error, response} = Management.create_product(product)
      assert response.errors == expected_errors
    end

    test "returns error when barcode has more than 13 digits", %{valid_attrs: attrs} do
      product = %{attrs | barcode: "12345678901234"}

      expected_errors = [
        barcode:
          {"should be at most %{count} character(s)",
           [count: 13, validation: :length, kind: :max, type: :string]}
      ]

      assert {:error, response} = Management.create_product(product)
      assert response.errors == expected_errors
    end
  end

  describe "update_product/2" do
    setup [:create_product]

    test "updates the product when data is valid", %{update_attrs: attrs, product: product} do
      assert {:ok, %Product{} = product} = Management.update_product(product, attrs)
      assert product.amount == 43
      assert product.description == "some updated description"
      assert product.name == "some updated name"
      assert product.price == 456.7
      assert product.sku == "some-updated-sku"
      assert product.barcode == "123456789"
    end

    test "returns error changeset when data is invalid", %{invalid_attrs: attrs, product: product} do
      expected_errors = [
        sku: {"can't be blank", [validation: :required]},
        amount: {"can't be blank", [validation: :required]},
        description: {"can't be blank", [validation: :required]},
        name: {"can't be blank", [validation: :required]},
        price: {"can't be blank", [validation: :required]},
        barcode: {"can't be blank", [validation: :required]}
      ]

      assert {:error, response} = Management.update_product(product, attrs)
      assert response.errors == expected_errors
    end

    test "returns error when the product is not found", %{update_attrs: attrs, product: product} do
      Management.delete_product(product)
      catch_error(Management.update_product(product, attrs))
    end
  end

  describe "delete_product/1" do
    setup [:create_product]

    test "deletes the product", %{product: product} do
      with_mock ElasticsearchService,
        delete: fn
          _path, _key, _value -> :ok
        end do
        assert {:ok, %Product{}} = Management.delete_product(product)
        assert_called(ElasticsearchService.delete(:_, :_, :_))
      end
    end

    test "returns error when product is not found", %{product: product} do
      Management.delete_product(product)
      catch_error(Management.delete_product(product))
    end
  end

  describe "change_product/1" do
    setup [:create_product]

    test "returns a product changeset", %{product: product} do
      assert %Ecto.Changeset{} = Management.change_product(product)
    end
  end

  defp product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        amount: 42,
        description: "some description",
        name: "some name",
        price: 120.5,
        sku: "some-sku",
        barcode: "123456789"
      })
      |> Management.create_product()

    product
  end

  defp create_product(_) do
    %{product: product_fixture()}
  end

  defp clear_els(_) do
    ElasticsearchService.clear()
    :ok
  end
end
