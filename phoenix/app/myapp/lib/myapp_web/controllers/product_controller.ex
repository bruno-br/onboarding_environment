defmodule MyappWeb.ProductController do
  use MyappWeb, :controller
  use Plug.ErrorHandler

  alias Myapp.Management
  alias Myapp.Management.Product

  action_fallback MyappWeb.FallbackController

  def index(conn, _params) do
    products = Management.list_products()
    render(conn, "index.json", products: products)
  end

  def create(conn, %{"product" => product_params}) do
    case Management.create_product(product_params) do
      {:ok, %Product{} = product} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.product_path(conn, :show, product))
        |> render("show.json", product: product)

      _ ->
        send_resp(conn, :bad_request, "")
    end
  end

  def create(conn, _different_params) do
    send_resp(conn, :bad_request, "")
  end

  def show(conn, %{"id" => id}) do
    product = Management.get_product!(id)

    if product == nil do
      send_resp(conn, :not_found, "")
    else
      render(conn, "show.json", product: product)
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Management.get_product!(id)

    if product == nil do
      send_resp(conn, :not_found, "")
    end

    case Management.update_product(product, product_params) do
      {:ok, %Product{} = product} -> render(conn, "show.json", product: product)
      _ -> send_resp(conn, :bad_request, "")
    end
  end

  def update(conn, _different_params) do
    send_resp(conn, :bad_request, "")
  end

  def delete(conn, %{"id" => id}) do
    product = Management.get_product!(id)

    if product == nil do
      send_resp(conn, :not_found, "")
    end

    case Management.delete_product(product) do
      {:ok, %Product{}} -> send_resp(conn, :no_content, "")
      _ -> send_resp(conn, :bad_request, "")
    end
  end
end
