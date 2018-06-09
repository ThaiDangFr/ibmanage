Rails.application.routes.draw do
  #get 'positions/index'
  #get 'positions/download'

  get 'pages/home'
#  resources :reports

  get 'reports/index_download'

  resources :reports do
    member do
      get 'download'
    end
  end

  resources :portfolios
  root 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
