Screw::Application.routes.draw do

  root :to => "welcome#index"

  devise_for :users
  get 'home', :to => 'stocks#index', :as => :user_root

  scope '/home' do
    resources :stocks
  end

end
