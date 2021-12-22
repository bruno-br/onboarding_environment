defmodule Myapp.ManagementTest do
  use Myapp.DataCase

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

  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Management.create_product()

    product
  end

  describe "list_products/0" do
    test "returns all products" do
      product = product_fixture()
      assert Management.list_products() == [product]
    end
  end

  describe "get_product!/1" do
    test "returns the product with given id" do
      product = product_fixture()
      assert Management.get_product!(product.id) == product
    end
  end

  describe "create_product/1" do
    test "creates a product when data is valid" do
      assert {:ok, %Product{} = product} = Management.create_product(@valid_attrs)
      assert product.amount == 42
      assert product.description == "some description"
      assert product.name == "some name"
      assert product.price == 120.5
      assert product.sku == "some-sku"
      assert product.barcode == "123456789"
    end

    test "returns error when data is invalid" do
      assert {:error, %Ecto.Changeset{}} = Management.create_product(@invalid_attrs)
    end

    test "returns error when sku is invalid" do
      product = %{@valid_attrs | sku: "invalid sku !!"}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "returns error when name is missing" do
      product = Map.delete(@valid_attrs, :name)
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "returns error when price is not greater than zero" do
      product = %{@valid_attrs | price: 0}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "returns error when barcode has less than 8 digits" do
      product = %{@valid_attrs | barcode: "1234567"}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "returns error when barcode has more than 13 digits" do
      product = %{@valid_attrs | barcode: "12345678901234"}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end
  end

  describe "update_product/2" do
    test "updates the product when data is valid" do
      product = product_fixture()
      assert {:ok, %Product{} = product} = Management.update_product(product, @update_attrs)
      assert product.amount == 43
      assert product.description == "some updated description"
      assert product.name == "some updated name"
      assert product.price == 456.7
      assert product.sku == "some-updated-sku"
      assert product.barcode == "123456789"
    end

    test "returns error changeset when data is invalid" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Management.update_product(product, @invalid_attrs)
      assert product == Management.get_product!(product.id)
    end
  end

  describe "delete_product/1" do
    test "deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Management.delete_product(product)
    end
  end

  describe "change_product/1" do
    test "returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Management.change_product(product)
    end
  end
end
