defmodule Myapp.Management.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :amount, :integer
    field :description, :string
    field :name, :string
    field :price, :float
    field :sku, :string

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:sku, :amount, :description, :name, :price])
    |> validate_required([:sku, :amount, :description, :name, :price])
  end
end
