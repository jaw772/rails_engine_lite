class MerchantsFindController < ApplicationController
  def search_all
    if params[:name]
      merchant = Merchant.where("name ILIKE ?", "%#{params[:name]}%")
      if merchant == nil
        render json: MerchantSerializer.new(Merchant.create())
      else
        render json: MerchantSerializer.new(merchant)
      end
    else
      render json: MerchantSerializer.new(Merchant.create())
    end
  end

  def search_one
    if params[:name]
      merchant = Merchant.where("name ILIKE ?", "%#{params[:name]}%").sort.first
      if merchant == nil
        render json: MerchantSerializer.new(Merchant.create())
      else
        render json: MerchantSerializer.new(merchant)
      end
    else
      render json: MerchantSerializer.new(Merchant.create())
    end
  end 
end
