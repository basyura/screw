class HomeController < ApplicationController
  before_filter :authenticate_user!
  def index
    @stock  = Stock.new
    read = params[:read]
    @stocks = current_user.stocks
    if !read || read.to_i != 1
      @stocks = @stocks.where(:read => 0)
    end
  end
end
