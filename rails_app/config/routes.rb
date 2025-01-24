Rails.application.routes.draw do
  devise_for :users
  root 'home#index'
  get 'overview', to: 'home#overview'
  get 'psalm_tunes', to: 'home#required_psalm_tunes'
  get 'chant_of_the_day', to: 'home#chant_of_the_day'

  resources :chants do
    collection do
      # endpoints for opening chant views from external applications which don't know
      # adiutor's entity IDs, but know the FIAL of each score
      post '/fial', to: 'browse_fial#list', as: :fial_list
      get '/fial/:fial', to: 'browse_fial#detail', as: :fial, constraints: {fial: /[^\/]+/}

      get 'resp-atyp', action: :atypical_responsories
      get 'clusters', action: :clusters

      post 'open_in_editor_retry', as: :retry_open_in_editor
    end

    member do
      post 'open_in_editor', as: :open_in_editor
      post 'add_quality_notice', as: :add_quality_notice
      get '/compare/:other_id', action: :compare, as: :compare
      get 'src', action: :source, as: :source
    end
  end

  resources :mismatches do
    member do
      post 'resolve', as: :resolve
    end
  end

  resources :corpora do
    member do
      get 'overview', as: :overview
      get 'differentiae', as: :differentiae
    end
  end

  resources :source_files

  # API for https://github.com/igneus/eantifonar2
  namespace :api do
    post 'eantifonar/search', to: 'eantifonar#search'
  end

  get '/gregobase', to: redirect('gregobase/sources#index')
  namespace :gregobase do
    resources :sources do
      resources :chants
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
