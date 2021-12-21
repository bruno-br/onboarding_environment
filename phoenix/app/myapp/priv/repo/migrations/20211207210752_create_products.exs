defmodule Myapp.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :sku, :string
      add :amount, :integer
      add :description, :text
      add :name, :string
      add :price, :float
      add :barcode, :string

      timestamps()
    end

  end
end
