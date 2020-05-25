json.items @items do |item|
  json.partial! 'full_item', item: item
end

json.partial! 'api/v1/shared/pagination'

json.types Item.type.values
