require 'rails_helper'

RSpec.describe 'Items' do
  describe 'Index' do
    it 'returns all items' do
      create_list(:item, 5)

      get "/api/v1/items"
      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      items[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes]).to have_key(:unit_price)
      end
    end
  end

  describe 'Show' do
    it 'returns a specific item' do
      item_1 = create(:item)

      get "/api/v1/items/#{item_1.id}"

      expect(response).to be_successful

      item = JSON.parse(response.body, symbolize_names: true)

      expect(item[:data][:id]).to eq item_1.id.to_s
      expect(item[:data][:attributes]).to have_key(:name)
      expect(item[:data][:attributes]).to have_key(:description)
      expect(item[:data][:attributes]).to have_key(:unit_price)
    end
  end

  describe 'Create' do
    it 'a new item' do
      merchant = create(:merchant)
      item_params = ({
        name: "Super Bouncy Ball",
        description: "Rainbow",
        unit_price: 4.44,
        merchant_id: merchant.id
        })
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
      created_item = Item.last

      expect(response).to be_successful
      expect(created_item.name).to eq "Super Bouncy Ball"
      expect(created_item.description).to eq "Rainbow"
      expect(created_item.unit_price).to eq 4.44
    end
  end

  describe 'Edit' do
    it 'an existing item' do
      merchant_1 = create(:merchant)
      item_1 = create(:item, name: "Flat Dull Ball", description: "Gray", unit_price: 1.11)
      new_item_params = ({
        name: "Super Bouncy Ball",
        description: "Rainbow",
        unit_price: 4.44,
        })
      headers = {"CONTENT_TYPE" => "application/json"}

      put "/api/v1/items/#{item_1.id}", headers: headers, params: JSON.generate(item: new_item_params)
      updated_item = Item.last

      expect(response).to be_successful
      expect(updated_item.id).to eq item_1.id
      expect(updated_item.name).to eq "Super Bouncy Ball"
      expect(updated_item.name).to_not eq "Flat Dull Ball"
      expect(updated_item.description).to eq "Rainbow"
      expect(updated_item.unit_price).to eq 4.44
    end
  end

  describe 'Delete' do
    it 'an existing item' do
      item_1 = create(:item)

      delete "/api/v1/items/#{item_1.id}"

      expect(response).to be_successful
      expect(Item.count).to eq 0
      expect{Item.find(item_1.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'Items Merchant' do
    it 'returns the merchant associated with item' do
      merchant_1 = create(:merchant)
      item_1 = create(:item, merchant: merchant_1)

      get "/api/v1/items/#{item_1.id}/merchant"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant[:data][:id]).to eq(item_1.merchant_id.to_s)
      expect(merchant[:data][:attributes]).to have_key(:name)
    end
  end

  describe 'Find_Item' do
    it '#search_one name' do
      create(:item, name: "Small Aluminum Bag")
      create(:item, name: "Rustic Plastic Computer")
      create(:item, name: "Rustic Marble Bench")
      create(:item, name: "Durable Concrete Bottle")

      get "/api/v1/items/find?name=TiC"
       expect(response).to be_successful

      item = JSON.parse(response.body, symbolize_names: true)

      expect(item[:data][:attributes][:name]).to eq "Rustic Plastic Computer"
    end
    it '#search_one min_price' do
      create(:item, unit_price: 1.11, name: "Small Aluminum Bag")
      create(:item, unit_price: 3.33, name: "Rustic Plastic Computer")
      create(:item, unit_price: 5.55, name: "Rustic Marble Bench")
      create(:item, unit_price: 7.77, name: "Durable Concrete Bottle")

      get "/api/v1/items/find?min_price=5"
       expect(response).to be_successful

      item = JSON.parse(response.body, symbolize_names: true)

      expect(item[:data][:attributes][:name]).to eq "Durable Concrete Bottle"
    end

    it '#search_one max_price' do
      create(:item, unit_price: 1.11, name: "Small Aluminum Bag")
      create(:item, unit_price: 3.33, name: "Rustic Plastic Computer")
      create(:item, unit_price: 5.55, name: "Rustic Marble Bench")
      create(:item, unit_price: 7.77, name: "Durable Concrete Bottle")

      get "/api/v1/items/find?max_price=5"
       expect(response).to be_successful

      item = JSON.parse(response.body, symbolize_names: true)

      expect(item[:data][:attributes][:name]).to eq "Rustic Plastic Computer"
    end

    it '#search_all' do
      create(:item, name: "Small Aluminum Bag")
      create(:item, name: "Rustic Plastic Computer")
      create(:item, name: "Rustic Marble Bench")
      create(:item, name: "Durable Concrete Bottle")

      get "/api/v1/items/find_all?name=TiC"
       expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      name_list = items[:data].map {|item| item[:attributes][:name]}
      expect(name_list.include?("Rustic Plastic Computer")).to be true
      expect(name_list.include?("Rustic Marble Bench")).to be true
      expect(name_list.include?("Durable Concrete Bottle")).to be false
    end

    describe 'sad paths' do
      it '#update incorrect info given' do
        item_1 = create(:item, name: "Flat Dull Ball", description: "Gray", unit_price: 1.11)
        new_item_params = ({
          name: "Super Bouncy Ball",
          description: "Rainbow",
          unit_price: "",
          })
        headers = {"CONTENT_TYPE" => "application/json"}

        put "/api/v1/items/#{item_1.id}", headers: headers, params: JSON.generate(item: new_item_params)

        expect(response).to_not be_successful
      end

      it '#search_one, max_price value is less than 0' do
        create(:item, unit_price: 1.11, name: "Small Aluminum Bag")
        create(:item, unit_price: 3.33, name: "Rustic Plastic Computer")
        create(:item, unit_price: 5.55, name: "Rustic Marble Bench")
        create(:item, unit_price: 7.77, name: "Durable Concrete Bottle")

        get "/api/v1/items/find?max_price=-5"
        expect(response).to_not be_successful

        item = JSON.parse(response.body, symbolize_names: true)

        expect(item[:error]).to eq "error"
      end

      it '#search_one, min_price value is less than 0' do
        create(:item, unit_price: 1.11, name: "Small Aluminum Bag")
        create(:item, unit_price: 3.33, name: "Rustic Plastic Computer")
        create(:item, unit_price: 5.55, name: "Rustic Marble Bench")
        create(:item, unit_price: 7.77, name: "Durable Concrete Bottle")

        get "/api/v1/items/find?min_price=-5"
        expect(response).to_not be_successful

        item = JSON.parse(response.body, symbolize_names: true)

        expect(item[:error]).to eq "error"
      end

      it '#search_one, multiple queries are used' do
        create(:item, unit_price: 1.11, name: "Small Aluminum Bag")

        get "/api/v1/items/find?name=ring&max_price=50"

        expect(response).to_not be_successful
        expect(response.status).to eq 400
      end

      it '#search_one, name result is not found' do
        create(:item, name: "Small Aluminum Bag")
        create(:item, name: "Rustic Plastic Computer")
        create(:item, name: "Rustic Marble Bench")
        create(:item, name: "Durable Concrete Bottle")

        get "/api/v1/items/find?name=too"
        expect(response).to_not be_successful
        expect(response.status).to eq 400
      end

      it '#search_one, min_price result is not found' do
        create(:item, unit_price: 1.11, name: "Small Aluminum Bag")
        create(:item, unit_price: 3.33, name: "Rustic Plastic Computer")
        create(:item, unit_price: 5.55, name: "Rustic Marble Bench")
        create(:item, unit_price: 7.77, name: "Durable Concrete Bottle")

        get "/api/v1/items/find?min_price=12.00"
        expect(response).to_not be_successful
        expect(response.status).to eq 400
      end

      it '#search_one, max_price result is not found' do
        create(:item, unit_price: 1.11, name: "Small Aluminum Bag")
        create(:item, unit_price: 3.33, name: "Rustic Plastic Computer")
        create(:item, unit_price: 5.55, name: "Rustic Marble Bench")
        create(:item, unit_price: 7.77, name: "Durable Concrete Bottle")

        get "/api/v1/items/find?max_price=1.00"
        expect(response).to_not be_successful
        expect(response.status).to eq 400
      end

      it '#search_all, name result is not found' do
        create(:item, name: "Small Aluminum Bag")
        create(:item, name: "Rustic Plastic Computer")
        create(:item, name: "Rustic Marble Bench")
        create(:item, name: "Durable Concrete Bottle")

        get "/api/v1/items/find_all?name=t34"
        item = JSON.parse(response.body, symbolize_names: true)
        expect(response).to be_successful
        expect(response.status).to eq 200
        expect(item[:data]).to eq []
      end

      it '#search_all no query given' do
        create(:item, name: "Small Aluminum Bag")
        create(:item, name: "Rustic Plastic Computer")
        create(:item, name: "Rustic Marble Bench")
        create(:item, name: "Durable Concrete Bottle")

        get "/api/v1/items/find_all?"
        expect(response).to_not be_successful
        expect(response.status).to eq 400
      end

      it '#search_one no query given' do
        create(:item, name: "Small Aluminum Bag")
        create(:item, name: "Rustic Plastic Computer")
        create(:item, name: "Rustic Marble Bench")
        create(:item, name: "Durable Concrete Bottle")

        get "/api/v1/items/find?"
        expect(response).to_not be_successful
        expect(response.status).to eq 400
      end
    end
  end
end
