defmodule MyappWeb.ProductController do
  use MyappWeb, :controller
  use Plug.ErrorHandler

  alias Myapp.Management
  alias Myapp.Management.Product
  alias MyappWeb.Plugs.GetProductPlug

  plug(GetProductPlug when action in [:show, :update, :delete])

  action_fallback(MyappWeb.FallbackController)

  def index(conn, params) do
    params
    |> Map.to_list()
    |> Management.list_products()
    |> send_products_list(conn)
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

  def create(conn, _different_params), do: send_bad_request(conn)

  def show(conn, %{"id" => _id}), do: send_product(conn, conn.assigns[:product])

  def update(conn, %{"id" => _id, "product" => product_params}) do
    with %Product{} = product <- conn.assigns[:product],
         {:ok, %Product{} = updated_product} <- Management.update_product(product, product_params) do
      send_product(conn, updated_product)
    end
  end

  def update(conn, _different_params), do: send_bad_request(conn)

  def delete(conn, %{"id" => _id}) do
    with %Product{} = product <- conn.assigns[:product],
         {:ok, %Product{}} <- Management.delete_product(product) do
      send_resp(conn, :no_content, "")
    else
      error -> error
    end
  end

  defp send_product(conn, product), do: render(conn, "show.json", product: product)

  defp send_products_list(products, conn), do: render(conn, "index.json", products: products)

  defp send_bad_request(conn), do: send_resp(conn, :bad_request, "")
end
