json.product_types do
  json.partial! 'api/v1/product_types/product_type', collection: @product_types, as: :product_type
end
