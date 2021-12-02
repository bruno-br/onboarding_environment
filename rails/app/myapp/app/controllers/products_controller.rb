# frozen_string_literal: true

# Controller for Products
class ProductsController < ApplicationController
  rescue_from Exception, with: :error_handler

  def index
    products = Product.all
    render json: { products: products }
  end

  def show
    product = Product.find_by(id: params[:id])

    if product.nil?
      render json: {}, status: :not_found
    else
      render json: { product: product }, status: :ok
    end
  end

  def create
    product = Product.new(permitted_params)

    if product.save
      render json: { message: 'Created', product: product }, status: :created
    else
      render json: {}, status: :bad_request
    end
  end

  def destroy
    product = Product.find_by(id: params[:id])
    if !product.nil?
      product.destroy
      render json: { message: 'Deleted', product: product }, status: :ok
    else
      render json: {}, status: :not_found
    end
  end

  def update
    product = Product.find_by(id: params[:id])

    return render json: {}, status: :not_found if product.nil?

    if product.update_attributes(permitted_params)
      render json: { message: 'Updated', product: product }, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  private

  def permitted_params
    params.permit(:sku, :name, :description, :amount, :price)
  end

  def error_handler
    render json: { error: true }, status: :error
  end
end
