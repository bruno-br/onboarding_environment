defmodule Myapp.ManagementTest do
  use Myapp.DataCase, async: false

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

  describe "list_products/0" do
    setup [:create_product]

    test "returns all products", %{product: product} do
      assert Management.list_products() == [product]
    end
  end

  describe "get_product!/1" do
    setup [:create_product]

    test "returns the product with given id", %{product: product} do
      assert Management.get_product!(product.id) == product
    end

    test "returns nil when product is not found" do
      assert Management.get_product!("invalid_id") == nil
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
      assert {:error, %Ecto.Changeset{}} = Management.create_product(attrs)
    end

    test "returns error when sku is invalid", %{valid_attrs: attrs} do
      product = %{attrs | sku: "invalid sku !!"}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "returns error when name is missing", %{valid_attrs: attrs} do
      product = Map.delete(attrs, :name)
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "returns error when price is not greater than zero", %{valid_attrs: attrs} do
      product = %{attrs | price: 0}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "returns error when barcode has less than 8 digits", %{valid_attrs: attrs} do
      product = %{attrs | barcode: "1234567"}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "returns error when barcode has more than 13 digits", %{valid_attrs: attrs} do
      product = %{attrs | barcode: "12345678901234"}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
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
      assert {:error, %Ecto.Changeset{}} = Management.update_product(product, attrs)
      assert product == Management.get_product!(product.id)
    end
  end

  describe "delete_product/1" do
    setup [:create_product]

    test "deletes the product", %{product: product} do
      assert {:ok, %Product{}} = Management.delete_product(product)
    end
  end

  describe "change_product/1" do
    setup [:create_product]

    test "returns a product changeset", %{product: product} do
      assert %Ecto.Changeset{} = Management.change_product(product)
    end
  end

  def product_fixture(attrs \\ %{}) do
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

  def create_product(_) do
    %{product: product_fixture()}
  end
end
