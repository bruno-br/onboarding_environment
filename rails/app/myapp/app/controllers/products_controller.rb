class ProductsController < ApplicationController
    # rescue_from Exception, :with => :error_handler

    def list_all
        products = Product.all
        render json: {data: products}
    end

    def get_by_id
        product = Product.find_by(id: params[:id])
        render json: {data: product}
    end

    def create
        required_params = [:SKU, :amount, :description, :name, :price]
        missing_params = []

        # Check for missing params
        for param in required_params
            if !params.has_key?(param)
                missing_params.push(param)
            end
        end

        # Returns missing params
        if missing_params.length > 0
            return render json: {error: true, message: "Missing params: "+missing_params.join(', ')}, status: :error
        end

        # Create and save new Product
        product = Product.new(SKU: params[:SKU], amount: params[:amount], description: params[:description], name: params[:name], price: params[:price])

        if product.save
            render json: {data:product},status: :created
        else
            render json: {error: true, data: nil}, status: :error
        end
    end

    def error_handler
        render json: {error: true, data: nil}, status: :error
    end
end
