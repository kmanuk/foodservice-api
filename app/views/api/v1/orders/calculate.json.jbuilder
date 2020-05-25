json.order do
  json.price          @price.price
  json.total_price    @price.total_price
  json.fee_price      @price.fee_price
  json.service_fee    @price.service_fee
  json.global_price   @price.global_price
  json.delivery_price @price.delivery_price
  json.distance       @price.distance
  json.duration       @price.duration
end
