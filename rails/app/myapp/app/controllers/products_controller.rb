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
    product = Product.new(sku: params[:sku], amount: params[:amount], description: params[:description],
                          name: params[:name], price: params[:price])

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
    valid_params = find_valid_params(%i[sku amount description name price], params)
    product = Product.find_by(id: params[:id])

    return render json: {}, status: :not_found if product.nil?

    # Update all valid_params
    valid_params.each do |param|
      is_success = product.update_attribute(param[:name], param[:value])
      render json: { message: "Error adding attribute #{param[:name]}" }, status: :error unless is_success
    end

    render json: { message: 'Updated', product: product }, status: :ok
  end

  private

  def error_handler
    render json: { error: true }, status: :error
  end

  def find_valid_params(valid_attributes, params)
    valid_params = []
    # Check all params that are valid attributes
    valid_attributes.each do |attribute|
      valid_params.push({ name: attribute.to_s, value: params[attribute] }) if params.key?(attribute)
    end
    valid_params
  end
end
