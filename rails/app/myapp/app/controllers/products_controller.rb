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
      render json: {}, status: 404
    else
      render json: { product: product }, status: :ok
    end
  end

  def create
    missing_params = check_for_missing_params(%i[SKU amount description name price])

    if missing_params.length > 0
      return render json: { error: true, message: "Missing params: #{missing_params.join(', ')}" },
                    status: 400
    end

    product = Product.new(SKU: params[:SKU], amount: params[:amount], description: params[:description],
                          name: params[:name], price: params[:price])

    if product.save
      render json: { message: 'Created', data: product }, status: :created
    else
      render json: { error: true, message: 'Failed' }, status: 400
    end
  end

  def destroy
    product = Product.find_by(id: params[:id])
    if !product.nil?
      product.destroy
      render json: { message: 'Deleted', product: product }, status: :ok
    else
      render json: {}, status: 404
    end
  end

  def update
    valid_params = find_valid_params(%i[SKU amount description name price], params)
    product = Product.find_by(id: params[:id])

    return render json: {}, status: 404 if product.nil?

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

  def check_for_missing_params(required_params)
    missing_params = []

    required_params.each do |param|
      missing_params.push(param) unless params.key?(param)
    end

    missing_params
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
