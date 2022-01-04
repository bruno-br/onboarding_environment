defmodule Myapp.Management do
  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false
  alias Myapp.Repo

  alias Myapp.Management.Product
  alias Myapp.Services.RedisService
  alias Myapp.Services.ElasticsearchService

  @doc """
  Returns the list of products.
  """
  def list_products() do
    case list_products_on_els() do
      {:ok, products_list} ->
        products_list

      :ok ->
        []

      _ ->
        extract_attrs_from_products(Repo.all(Product))
    end
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
    with product_changeset <- Product.changeset(%Product{}, attrs),
         {:ok, product} <- Repo.insert(product_changeset) do
      save_product_on_els(product)
      {:ok, product}
    else
      error -> error
    end
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

  defp save_product_on_els(product),
    do:
      ElasticsearchService.post(
        "products",
        Product.get_attrs(product)
      )

  defp extract_attrs_from_products([%Product{} | _] = products),
    do: Enum.map(products, fn product -> Product.get_attrs(product) end)

  defp extract_attrs_from_products(any), do: any

  defp list_products_on_els(), do: ElasticsearchService.list("products")
end
