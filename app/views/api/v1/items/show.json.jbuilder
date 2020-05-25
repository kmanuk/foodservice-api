json.item do
  json.partial! 'full_item', item: @item
end
json.types Item.type.values
