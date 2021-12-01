class ProductsController < ApplicationController
    def list_all
        products = Product.all
        render json: {status: products}
    end
end
