defmodule Myapp.Management.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

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
    |> validate_format(:sku, ~r/^([a-zA-Z0-9]|\-)+$/, message: "can only contain alphanumerics and hifen")
  end
end
