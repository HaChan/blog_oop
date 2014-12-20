Rails.application.routes.draw do
  get 'blog/index'

  root to: "blog#index"

  resources :posts
end
