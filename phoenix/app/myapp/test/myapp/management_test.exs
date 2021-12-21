defmodule Myapp.ManagementTest do
  use Myapp.DataCase

  alias Myapp.Management

  describe "products" do
    alias Myapp.Management.Product

    @valid_attrs %{
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

    def product_fixture(attrs \\ %{}) do
      {:ok, product} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Management.create_product()

      product
    end

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Management.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Management.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Management.create_product(@valid_attrs)
      assert product.amount == 42
      assert product.description == "some description"
      assert product.name == "some name"
      assert product.price == 120.5
      assert product.sku == "some-sku"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Management.create_product(@invalid_attrs)
    end

    test "create_product/1 returns error when sku is invalid" do
      product = %{@valid_attrs | sku: "invalid sku !!"}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "create_product/1 returns error when name is missing" do
      product = Map.delete(@valid_attrs, :name)
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "create_product/1 returns error when price is not greater than zero" do
      product = %{@valid_attrs | price: 0}
      assert {:error, %Ecto.Changeset{}} = Management.create_product(product)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, %Product{} = product} = Management.update_product(product, @update_attrs)
      assert product.amount == 43
      assert product.description == "some updated description"
      assert product.name == "some updated name"
      assert product.price == 456.7
      assert product.sku == "some-updated-sku"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Management.update_product(product, @invalid_attrs)
      assert product == Management.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Management.delete_product(product)
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Management.change_product(product)
    end
  end
end
