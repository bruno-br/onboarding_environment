# frozen_string_literal: true

Myapp::Application.routes.draw do
  resources :products, only: %i[index show create update destroy]
end
