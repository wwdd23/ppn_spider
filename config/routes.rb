Rails.application.routes.draw do
  root to: "dashbord#index"

  mount Qspider::API => '/api'

  # resources :houses, only: [] do
  #   get 'sight_photos', on: :collection
  #   get 'house_photos', on: :collection
  #   get 'mafengwo_redirect', on: :collection
  #   put 'update_sight_photos', on: :collection
  # end

  resources :dashbord, only: [:index]
end
