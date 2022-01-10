defmodule MyappWeb.ProductController do
  use MyappWeb, :controller
  use Plug.ErrorHandler

  alias Myapp.Management
  alias Myapp.Management.Product
  alias MyappWeb.Plugs.GetProductPlug

  plug(GetProductPlug when action in [:show, :update, :delete])

  action_fallback(MyappWeb.FallbackController)

  def index(_conn, params) do
    products =
      params
      |> Map.to_list()
      |> Management.list_products()

    {:index, products}
  end

  def create(_conn, %{"product" => product_params}) do
    case Management.create_product(product_params) do
      {:ok, %Product{} = product} ->
        {:created, product}

      error ->
        error
    end
  end

  def show(conn, %{"id" => _id}), do: {:ok, conn.assigns[:product]}

  def update(conn, %{"id" => _id, "product" => product_params}) do
    with %Product{} = product <- conn.assigns[:product],
         {:ok, %Product{} = updated_product} <- Management.update_product(product, product_params) do
      {:ok, updated_product}
    end
  end

  def delete(conn, %{"id" => _id}) do
    with %Product{} = product <- conn.assigns[:product],
         {:ok, %Product{}} <- Management.delete_product(product) do
      :no_content
    else
      error -> error
    end
  end
end
