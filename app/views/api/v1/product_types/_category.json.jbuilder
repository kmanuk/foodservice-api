json.(category, :id, :name, :description)

json.sub_categories do
  json.partial! 'sub_category', collection: category.sub_categories, as: :sub_category
end

if category.image
  json.url   asset_url category.image.data.url
end
