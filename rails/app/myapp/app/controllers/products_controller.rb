class ProductsController < ApplicationController
    def list_all
        products = Product.all
        render json: {data: products}
    end

    def get_by_id
        product = Product.find_by(id: params[:id])
        render json: {data: product}
    end
end
