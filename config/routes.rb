Typhoo::Application.routes.draw do

  root :to => "welcome#index"

  devise_for :users
  get 'home', :to => 'stocks#index', :as => :user_root

  resources :home , :controller => 'stocks'
  resources :stocks

end
