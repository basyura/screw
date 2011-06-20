class StocksController < ApplicationController
  before_filter :authenticate_user!
  def index
    @stock  = Stock.new
    read = params[:read]
    @stocks = current_user.stocks
    if !read || read.to_i != 1
      @stocks = @stocks.where(:read => 0)
    end
  end
  def create
    redirect_to :user_root , :notice => "#{params[:stock][:url]} is already exist."
    return
    if Stock.where(:url => params[:stock][:url]).first
      redirect_to :user_root , :notice => "#{params[:stock][:url]} is already exist."
    else @stock
      Stock.new(params[:stock]).save
      redirect_to :user_root
    end
  end
  def show
    @stock = Stock.find(params[:id])
    @page  = Page.where(:url => @stock.url).first
    unless @page
      @page = Page.crawl(stock.url)
      @page.save
    end
  end
  def update
    stock = Stock.find(params[:id])
    stock.update_attributes(params[:stock])
    stock.save
    redirect_to :user_root
  end
  def destroy
    @stock= Stock.find(params[:id])
    @stock.destroy
    redirect_to :user_root
  end
end
