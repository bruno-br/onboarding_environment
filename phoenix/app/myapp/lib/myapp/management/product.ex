defmodule Myapp.Management.Product do
  @moduledoc """
  Product model
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "products" do
    field(:amount, :integer)
    field(:description, :string)
    field(:name, :string)
    field(:price, :float)
    field(:sku, :string)
    field(:barcode, :string)

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:sku, :amount, :description, :name, :price, :barcode])
    |> validate_required([:sku, :amount, :description, :name, :price, :barcode])
    |> validate_format(:sku, ~r/^([a-zA-Z0-9]|\-)+$/,
      message: "can only contain alphanumerics and hifen"
    )
    |> validate_number(:price, greater_than: 0)
    |> validate_length(:barcode, min: 8, max: 13)
  end

  def get_attrs(product) do
    %{
      amount: product.amount,
      barcode: product.barcode,
      description: product.description,
      id: product.id,
      name: product.name,
      price: product.price,
      sku: product.sku
    }
  end
end
