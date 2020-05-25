class Api::V1::ItemsController < ApiController
  resource_description do
    formats [:json]
    api_version 'v1'
  end
  include Docs::V1::Items

  before_action :authenticate_user!, only: [:seller_items, :create, :update, :destroy]
  before_action :find_item, only: [:update, :destroy]

  def index
    result = Items::Index.call(params: params, user: current_user)
    @items = result.items
    @pagination = result.result_paginations
    render_result(result, :index)
  end

  def last_item
    result = Items::Index.call(params: params, user: current_user)
    @item = result.items.last
    render_result(result, :show)
  end


  def preorder_items
    result = Items::PreorderItems.call(params: params)
    @sellers = result.sellers
    @pagination = result.result_paginations
    render_result(result, :preorder_items)
  end

  def seller_items
    result = Items::SellerItems.call(params: params, user: current_user)
    @items = result.items
    @pagination = result.result_paginations
    render_result(result, :index)
  end

  def show
    @item = Item.find params[:id]
  end

  def create
    @item = current_user.items.build(item_params)
    if @item.save
      render :show, status: :created
    else
      render_errors @item
    end
  end

  def update
    if @item.update(item_params)
      render :show, status: :ok
    else
      render_errors @item
    end
  end

  def destroy
    @item.destroy
    head :no_content
  end

  private

  def render_result(result, method)
    if result.success?
      render method, status: :ok
    else
      render_errors nil, result.errors
    end
  end

  def find_item
    @item = current_user.items.find params[:id]
  end

  def item_params
    params.require(:item).permit(
        :name, :product_type_id, :category_id, :sub_category_id,
        :information, :price, :amount, :time_to_cook, :type,
        image_attributes: [:data]
    )
  end
end
