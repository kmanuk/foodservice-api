json.orders @orders do |order|
  json.partial! 'order', order: order
end

json.partial! 'api/v1/shared/pagination'