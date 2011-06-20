class WelcomeController < ApplicationController
  def index
    redirect_to :user_root if current_user
  end
end
