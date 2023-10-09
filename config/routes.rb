Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get "/ping", to: proc { [200, {}, ["pong"]] }

  namespace :annecdotes do
    get :example_2_a, :example_2_b
  end
end
