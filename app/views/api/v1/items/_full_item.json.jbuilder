json.partial! 'item', item: item
json.seller do
  json.partial! 'api/v1/users/seller', user: item.user
end

