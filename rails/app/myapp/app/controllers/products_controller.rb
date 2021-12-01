# frozen_string_literal: true

# Controller for Products
class ProductsController < ApplicationController
  # rescue_from Exception, :with => :error_handler

  def list_all
    products = Product.all
    render json: { data: products }
  end

  def find_by_id
    product = Product.find_by(id: params[:id])
    render json: { data: product }
  end

  def create
    # Check if any params are missing
    required_params = %i[SKU amount description name price]
    check_for_missing_params(required_params)

    # Create and save new Product
    product = Product.new(SKU: params[:SKU], amount: params[:amount], description: params[:description],
                          name: params[:name], price: params[:price])

    if product.save
      render json: { data: product }, status: :created
    else
      render json: { error: true, data: nil }, status: :error
    end
  end

  def delete
    product = Product.find_by(id: params[:id])
    if !product.nil?
      product.destroy
      render json: { message: 'Deleted', data: product }, status: :ok
    else
      render json: { message: 'Product not found', data: nil }, status: :error
    end
  end

  private

  def error_handler
    render json: { error: true, data: nil }, status: :error
  end

  def check_for_missing_params
    missing_params = []

    # Check for missing params
    :required_params.each do |param|
      missing_params.push(param) unless params.key?(param)
    end

    message = "Missing params: #{missing_params.join(', ')}"

    # Returns missing params
    return unless missing_params.length.positive? render json: { error: true, message: message },
                                                         status: :error
  end
end
