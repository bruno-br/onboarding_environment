defmodule Myapp.Management do
  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false
  alias Myapp.Repo

  alias Myapp.Management.Product
  alias Myapp.RedisApi

  @doc """
  Returns the list of products.
  """
  def list_products do
    client = RedisApi.start()

    case RedisApi.get(client, "product_list") do
      {:ok, products} ->
        products

      {:error, :not_found} ->
        products = Repo.all(Product)
        RedisApi.set(client, "product_list", products)
        products

      _ ->
        Repo.all(Product)
    end
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.
  """
  def get_product!(id) do
    Repo.get(Product, id)
  rescue
    Ecto.Query.CastError -> nil
  end

  @doc """
  Creates a product.
  """
  def create_product(attrs \\ %{}) do
    delete_from_cache("product_list")

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
    delete_from_cache("product_list")
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  defp delete_from_cache(key), do: RedisApi.del(RedisApi.start(), key)
end
