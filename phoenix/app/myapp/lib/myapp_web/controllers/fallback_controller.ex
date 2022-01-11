defmodule MyappWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use MyappWeb, :controller
  alias Myapp.Management.Product

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(MyappWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}),
    do: send_resp(conn, :not_found, "")

  # Matches other errors
  def call(conn, {:error, _any}),
    do: send_resp(conn, :bad_request, "")

  def call(conn, {:index, products}),
    do: render(conn, "index.json", products: products)

  def call(conn, {:ok, %Product{} = product}),
    do: render(conn, "show.json", product: product)

  def call(conn, {:created, %Product{} = product}) do
    conn
    |> put_status(:created)
    |> render("show.json", product: product)
  end

  def call(conn, :no_content),
    do: send_resp(conn, :no_content, "")
end
