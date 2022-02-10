class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name
  set_type :merchant
  set_id :id
end
