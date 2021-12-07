defmodule MyappWeb.ProductController do
  use MyappWeb, :controller

  alias Myapp.Management
  alias Myapp.Management.Product

  action_fallback MyappWeb.FallbackController

  def index(conn, _params) do
    products = Management.list_products()
    render(conn, "index.json", products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <- Management.create_product(product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.product_path(conn, :show, product))
      |> render("show.json", product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Management.get_product!(id)
    render(conn, "show.json", product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Management.get_product!(id)

    with {:ok, %Product{} = product} <- Management.update_product(product, product_params) do
      render(conn, "show.json", product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Management.get_product!(id)

    with {:ok, %Product{}} <- Management.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
