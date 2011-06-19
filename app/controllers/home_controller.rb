class HomeController < ApplicationController
  before_filter :authenticate_user!
  def index
    puts params.class.to_s
    @stock  = Stock.new
    @stocks = current_user.stocks
  end
end
