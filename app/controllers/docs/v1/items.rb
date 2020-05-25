module Docs::V1::Items
  extend Apipie::DSL::Concern

  def_param_group :id do
    param :id, Integer, 'Item ID', required: true
  end

  def_param_group :item do
    param :item, Hash, requred: true do
      param :product_type_id, Integer, required: true
      param :category_id, Integer, required: true
      param :sub_category_id, Integer, required: true
      param :product_type_id, Integer, required: true
      param :information, String
      param :price, Float, required: true
      param :amount, Integer, required: true
      param :time_to_cook, Float, desc: 'for Preorder', required: true
      param :type, Item.type.values, required: true
      param :image_attributes, Hash do
        param :data, File
      end
    end
  end

  def_param_group :pagination do
    param :page, Integer
    param :limit, Integer
  end

  def_param_group :filter do
    param :filter, Hash, 'Search and sort params' do
      param :seller, Integer, 'Filter by Seller ID'
      param :product_type, Integer, 'Filter by Product Type ID'
      param :category, Integer, 'Filter by category ID'
      param :sub_category, Integer, 'Filter by Subcategory ID'
      param :search, Integer, 'Search by Name'
      param :type, Array, of: String,  desc: "Filter by Type ['live', 'free', 'preorder']"
      param :location, Hash do
        param :bottom_left_latitude, Float
        param :bottom_left_longitude, Float
        param :top_right_latitude, Float
        param :top_right_longitude, Float
      end
    end
  end

  api! 'List of items'
  param_group :filter
  param_group :pagination
  def index; end

  api! 'Last item on the page'
  param_group :filter
  param_group :pagination
  def last_item; end

  api! 'List of active sellers with preorder items'
  param_group :filter
  param_group :pagination
  def preorder_items; end

  api! "Seller's List of items"
  param_group :filter
  param_group :pagination
  def seller_items; end

  api! 'Show item'
  param_group :id
  param_group :item
  def show; end

  api! 'Create item'
  param_group :item
  def create; end

  api! 'Update item'
  param_group :id
  param_group :item
  def update; end

  api! 'Remove item'
  param_group :id
  def destroy; end
end
