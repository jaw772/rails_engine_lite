class MerchantsFindController < ApplicationController
  def search_all
    if params[:name]
      merchant = Merchant.where("name ILIKE ?", "%#{params[:name]}%")
      if merchant == []
        render json: MerchantSerializer.new(merchant)
      else
        render json: MerchantSerializer.new(merchant)
      end
    else
      render json: JSON.generate({error: 'error'}), status: 400
    end
  end

  def search_one
    if params[:name]
      merchant = Merchant.where("name ILIKE ?", "%#{params[:name]}%").sort.first
      if merchant == nil
        render json: JSON.generate({error: 'error'}), status: 400
      else
        render json: MerchantSerializer.new(merchant)
      end
    else
      render json: JSON.generate({error: 'error'}), status: 400
    end
  end
end
