json.extract! item,
              :id,
              :name,
              :sub_category_id,
              :product_type_id,
              :category_id,
              :information,
              :price,
              :amount,
              :time_to_cook,
              :type,
              :total_price

json.sub_category_title item.sub_category.title

if item.image
  json.url asset_url item.image.data.url
  json.thumb asset_url item.image.data.url(:thumb)
end
