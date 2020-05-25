class Api::V1::ProductTypesController < ApiController
  resource_description do
    formats [:json]
    api_version 'v1'
  end
  include Docs::V1::ProductTypes

  def index
    @product_types = ProductType.includes(categories: [:sub_categories])
  end
end
