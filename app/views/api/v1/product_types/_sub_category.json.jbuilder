json.(sub_category, :id, :name, :description)

if sub_category.image
  json.url   asset_url sub_category.image.data.url
end
