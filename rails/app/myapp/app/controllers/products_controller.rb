class ProductsController < ApplicationController
    def index
        # @products = Product.all
        render json: {status: 'SUCCESS'}
    end
end
