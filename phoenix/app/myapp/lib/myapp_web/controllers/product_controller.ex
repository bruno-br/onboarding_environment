defmodule MyappWeb.ProductController do
  use MyappWeb, :controller
  use Plug.ErrorHandler

  import MyappWeb.ProductPlug

  alias Myapp.Management
  alias Myapp.Management.Product

  plug :get_product when action in [:show, :update, :delete]

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
        |> render("show.json", product: product)

      _ ->
        send_resp(conn, :bad_request, "")
    end
  end

  def create(conn, _different_params) do
    send_resp(conn, :bad_request, "")
  end

  def show(conn, %{"id" => id}) do
    case conn.assigns[:get_product] do
      {:ok, %Product{} = product} -> render(conn, "show.json", product: product)
      {:error, :not_found} -> send_resp(conn, :not_found, "")
      _ -> send_resp(conn, :bad_request, "")
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    with {:ok, %Product{} = product} <- conn.assigns[:get_product],
         {:ok, %Product{} = updated_product} <- Management.update_product(product, product_params) do
      render(conn, "show.json", product: updated_product)
    else
      {:error, :not_found} -> send_resp(conn, :not_found, "")
      _ -> send_resp(conn, :bad_request, "")
    end
  end

  def update(conn, _different_params) do
    send_resp(conn, :bad_request, "")
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Product{} = product} <- conn.assigns[:get_product],
         {:ok, %Product{}} <- Management.delete_product(product) do
      send_resp(conn, :no_content, "")
    else
      {:error, :not_found} -> send_resp(conn, :not_found, "")
      _ -> send_resp(conn, :bad_request, "")
    end
  end
end
