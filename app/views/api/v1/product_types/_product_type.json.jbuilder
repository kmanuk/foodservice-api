json.(product_type, :id, :name)

if product_type.image
  json.url   asset_url product_type.image.data.url
end

json.categories do
  json.partial! 'category', collection: product_type.categories, as: :category
end
