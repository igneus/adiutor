Rails.application.routes.draw do
  root 'home#index'
  get 'overview', to: 'home#overview'

  resources :chants do
    member do
      post 'open_in_editor', as: :open_in_editor
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
