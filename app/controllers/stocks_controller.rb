class StocksController < ApplicationController
  def create
    if Stock.where(:url => params[:stock][:url]).first
      redirect_to :user_root , :notice => "#{params[:stock][:url]} is already exist."
    else @stock
      Stock.new(params[:stock]).save
      redirect_to :user_root
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
