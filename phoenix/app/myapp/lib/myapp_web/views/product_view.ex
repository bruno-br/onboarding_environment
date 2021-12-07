defmodule MyappWeb.ProductView do
  use MyappWeb, :view
  alias MyappWeb.ProductView

  def render("index.json", %{products: products}) do
    %{data: render_many(products, ProductView, "product.json")}
  end

  def render("show.json", %{product: product}) do
    %{data: render_one(product, ProductView, "product.json")}
  end

  def render("product.json", %{product: product}) do
    %{id: product.id,
      sku: product.sku,
      amount: product.amount,
      description: product.description,
      name: product.name,
      price: product.price}
  end
end
