defmodule Myapp.Management do
  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false

  alias Myapp.Repo
  alias Myapp.Management.Product
  alias Myapp.Services.{RedisService, ElasticsearchService}

  @doc """
  Returns the list of products.
  """

  def list_products(filters \\ []) do
    case list_products_on_els(filters) do
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
    product_key = "product_" <> to_string(id)

    case load_product_from_cache(product_key) do
      {:ok, product} ->
        product

      {:error, :not_found} ->
        product = Repo.get(Product, id)
        save_product_on_cache(product_key, product)
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
         {:ok, product} <- Repo.insert(product_changeset),
         {:ok, :created} <- save_product_on_els(product) do
      {:ok, product}
    else
      error -> error
    end
  end

  @doc """
  Updates a product.
  """
  def update_product(%Product{} = product, attrs) do
    with product_changeset <- Product.changeset(product, attrs),
         {:ok, updated_product} <- Repo.update(product_changeset),
         updated_product_attrs <- Product.get_attrs(updated_product),
         :ok <- update_product_on_els(updated_product_attrs) do
      {:ok, updated_product}
    else
      error ->
        error
    end
  end

  @doc """
  Deletes a product.
  """
  def delete_product(%Product{} = product) do
    delete_product_from_els(product)
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  """

  def change_product(%Product{} = product, attrs \\ %{}),
    do: Product.changeset(product, attrs)

  defp save_product_on_cache(key, %Product{} = product),
    do: RedisService.set(key, product)

  defp save_product_on_cache(_key, _any),
    do: :error

  defp load_product_from_cache(key),
    do: RedisService.get(key)

  defp list_products_on_els([{_key, _value} | _] = filters),
    do: ElasticsearchService.search("products", filters)

  defp list_products_on_els(_),
    do: ElasticsearchService.list("products")

  defp save_product_on_els(product),
    do:
      ElasticsearchService.post(
        "products",
        Product.get_attrs(product)
      )

  defp update_product_on_els(new_product),
    do:
      ElasticsearchService.update(
        "products",
        "id",
        new_product.id,
        new_product
      )

  defp delete_product_from_els(%Product{} = product),
    do: ElasticsearchService.delete("products", "id", product.id)

  defp extract_attrs_from_products([%Product{} | _] = products),
    do: Enum.map(products, fn product -> Product.get_attrs(product) end)

  defp extract_attrs_from_products(any), do: any
end
