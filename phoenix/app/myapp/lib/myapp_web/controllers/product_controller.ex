defmodule MyappWeb.ProductController do
  use MyappWeb, :controller
  use Plug.ErrorHandler

  alias Myapp.Management
  alias Myapp.Management.Product
  alias MyappWeb.Plugs.GetProductPlug

  plug(GetProductPlug when action in [:show, :update, :delete])

  action_fallback(MyappWeb.FallbackController)

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

      error ->
        error
    end
  end

  def create(conn, _different_params) do
    send_resp(conn, :bad_request, "")
  end

  def show(conn, %{"id" => _id}) do
    case conn.assigns[:get_product] do
      {:ok, %Product{} = product} -> render(conn, "show.json", product: product)
      error -> error
    end
  end

  def update(conn, %{"id" => _id, "product" => product_params}) do
    with {:ok, %Product{} = product} <- conn.assigns[:get_product],
         {:ok, %Product{} = updated_product} <- Management.update_product(product, product_params) do
      render(conn, "show.json", product: updated_product)
    end
  end

  def update(conn, _different_params) do
    send_resp(conn, :bad_request, "")
  end

  def delete(conn, %{"id" => _id}) do
    with {:ok, %Product{} = product} <- conn.assigns[:get_product],
         {:ok, %Product{}} <- Management.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
