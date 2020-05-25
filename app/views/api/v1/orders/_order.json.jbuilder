json.extract! order,
              :id,
              :price,
              :fee_price,
              :total_price,
              :service_fee,
              :delivery_price,
              :global_price,
              :status,
              :delivery_type,
              :payment_type,
              :type,
              :cooking_time,
              :distance,
              :duration,
              :polyline,
              :estimation_ready,
              :created_at

json.review order.review_added?

json.line_items order.line_items do |line_item|
  json.extract! line_item,
                :id,
                :name,
                :time_to_cook,
                :total_price,
                :price
  json.amount   line_item.quantity
  json.url   line_item.image_url
end

json.possible_statuses order.possible_statuses

json.next_status order.next_status
json.who_can_change order.who_can_change
json.who_can_cancel order.who_can_cancel


json.address do
  json.partial! 'api/v1/addresses/address', address: order.address

end


json.seller do
    json.partial! 'api/v1/users/seller', user: order.seller
end

json.buyer do
  json.partial! 'api/v1/users/basic', user: order.buyer
end


json.driver do
  if order.driver
    json.partial! 'api/v1/users/driver', user: order.driver
  else
    json.null!
  end

end
