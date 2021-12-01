# frozen_string_literal: true

class Product
  include Mongoid::Document
  field :SKU, type: String
  field :name, type: String
  field :description, type: String
  field :amount, type: Integer
  field :price, type: Float
end
