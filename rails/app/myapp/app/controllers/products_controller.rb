class ProductsController < ApplicationController
    rescue_from Exception, :with => :error_handler

    def list_all
        products = Product.all
        render json: {data: products}
    end

    def get_by_id
        product = Product.find_by(id: params[:id])
        render json: {data: product}
    end

    def error_handler
        render json: {error: true, data: nil}, status: :error
    end
end
