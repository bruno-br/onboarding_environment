defmodule Myapp.Management do
  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false
  alias Myapp.Repo

  alias Myapp.Management.Product
  alias Myapp.Services.RedisService

  @doc """
  Returns the list of products.
  """
  def list_products do
    client = RedisService.start()
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.
  """
  def get_product(id) do
    client = RedisService.start()

    product_key = "product_" <> to_string(id)

    case RedisService.get(client, product_key) do
      {:ok, product} ->
        product

      {:error, :not_found} ->
        product = Repo.get(Product, id)
        RedisService.set(client, product_key, product)
        product

      _ ->
        Repo.get(Product, id)
    end
  rescue
    Ecto.Query.CastError -> nil
  end

  @doc """
  Creates a product.
  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.
  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.
  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
