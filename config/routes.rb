Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :rides do
  end

  resources :stations do
  end

  root to: 'rides#main'
end
