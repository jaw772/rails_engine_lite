require 'rails_helper'

RSpec.describe 'Merchant' do
  describe 'Index' do
    it 'returns all merchants' do
      create_list(:merchant, 5)

      get '/api/v1/merchants'
      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].count).to eq(5)

      merchants[:data].each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:attributes]).to have_key(:name)
      end
    end
  end

  describe 'Show' do
    it 'returns one instance of merchant' do
      id = create(:merchant).id

      get "/api/v1/merchants/#{id}"

      merchant = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful

      expect(merchant[:data][:id]).to eq(id.to_s)
      expect(merchant[:data][:attributes]).to have_key(:name)
    end
  end

  describe 'Merchants Items' do
    it 'returns all items associated with merchant' do
      merchant_1 = create(:merchant)
      create_list(:item, 5, merchant: merchant_1)

      get "/api/v1/merchants/#{merchant_1.id}/items"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)
      items[:data].each do |item|
        expect(item[:attributes][:merchant_id]).to eq(merchant_1.id)
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes]).to have_key(:unit_price)
      end
    end
  end

  describe 'Find_Merchant' do
    it '#search_one' do
      create(:merchant, name: "Small Aluminum Company")
      create(:merchant, name: "Rustic Plastic Company")
      create(:merchant, name: "Rustic Marble Company")
      create(:merchant, name: "Durable Concrete Company")

      get "/api/v1/merchants/find?name=TiC"
       expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant[:data][:attributes][:name]).to eq "Rustic Plastic Company"
    end

    it '#search_all' do
      create(:merchant, name: "Small Aluminum Company")
      create(:merchant, name: "Rustic Plastic Company")
      create(:merchant, name: "Rustic Marble Company")
      create(:merchant, name: "Durable Concrete Company")

      get "/api/v1/merchants/find_all?name=TiC"
       expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      name_list = merchants[:data].map {|merchant| merchant[:attributes][:name]}
      expect(name_list.include?("Rustic Plastic Company")).to be true
      expect(name_list.include?("Rustic Marble Company")).to be true
      expect(name_list.include?("Durable Concrete Company")).to be false
    end
  end
end
