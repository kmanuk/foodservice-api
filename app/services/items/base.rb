class Items::Base
  include ApplicationHelper

  private


  def page_params
    @params.permit(:page, :limit)
  end


  def available_items
    Item.from_active_sellers.with_amount
  end

  def paginate_items
    total = @items.count
    @items = @items.paginate(page_params[:page], page_params[:limit])
    pagination(@items.current_page, @items.limit_value, total, @items.total_pages)
  end

  def add_image_and_filter
    @items = @items.include_image_and_filter(filter_params[:filter])
  end


  def filter_params
    @params.permit(filter: [:category,
                            :search,
                            :seller,
                            :sub_category,
                            :product_type,
                            :sellers_rate,
                            location: [:bottom_left_latitude, :bottom_left_longitude, :top_right_latitude, :top_right_longitude],
                            type: []])
  end

end
