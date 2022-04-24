Rails.application.routes.draw do
  root 'home#index'
  get 'overview', to: 'home#overview'
  get 'psalm_tunes', to: 'home#required_psalm_tunes'

  resources :chants do
    member do
      post 'open_in_editor', as: :open_in_editor
      get '/compare/:other_id', action: :compare, as: :compare
    end
  end

  resources :mismatches do
    member do
      post 'resolve', as: :resolve
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
