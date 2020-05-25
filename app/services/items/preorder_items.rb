class Items::PreorderItems < Items::Base
  include Interactor

  before do
    @params = context[:params]
  end


  def call
    @items = available_items.preorders
    add_image_and_filter
    @sellers = User.where(id: @items.pluck(:user_id).uniq)
    total = @sellers.count
    @sellers = @sellers.paginate(page_params[:page], page_params[:limit])
    pagination(@sellers.current_page, @sellers.limit_value, total, @sellers.total_pages)
  end

  after do
    context.sellers = @sellers
    context.result_paginations = @pagination
  end
end
