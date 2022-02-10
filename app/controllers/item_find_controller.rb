class ItemFindController < ApplicationController
  def search_one
    if params[:name] && (params[:min_price] || params[:max_price])
      render status: 400
    else
      if params[:name]
        item = Item.where("name ILIKE ?", "%#{params[:name]}%").sort.first
        if item == nil
          render json: ItemSerializer.new(Item.create()), status: 400
        else
          render json: ItemSerializer.new(item)
        end
      elsif params[:min_price]
        if params[:min_price].to_f > 0
            item = Item.where("unit_price >= ?", params[:min_price]).order(name: :asc).first
            if item == nil
              render json: ItemSerializer.new(Item.create()), status: 400
            else
              render json: ItemSerializer.new(item)
            end
        else
            render json: JSON.generate({error: 'error'}) , status: 400
        end
      elsif params[:max_price]
        if params[:max_price].to_f > 0
          item = Item.where("unit_price <= ?", params[:max_price]).order(name: :asc).first
          if item == nil
            render status: 400, json: ItemSerializer.new(Item.create().errors)
          else
            render json: ItemSerializer.new(item)
          end
        else
            render json: JSON.generate({error: 'error'}) , status: 400
        end
      end
    end
  end

  def search_all
    if params[:name]
      item = Item.where("name ILIKE ?", "%#{params[:name]}%")
      if item == nil
        render json: ItemSerializer.new(Item.create())
      else
        render json: ItemSerializer.new(item)
      end
    else
      render json: ItemSerializer.new(Item.create())
    end
  end
end
