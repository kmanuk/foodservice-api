class Api::V1::OrdersController < ApiController
  resource_description do
    formats [:json]
    api_version 'v1'
  end
  include Docs::V1::Orders

  before_action :authenticate_user!
  before_action :find_order, only: [:show]

  def index
    @orders = current_user.orders.paid_only.with_associations.filter(index_params[:filter]).order(id: :desc)
    paginate_orders
  end

  def show
  end

  def waiting_for_driver
    if current_user.online_driver?
      @orders = Order.looking_driver.with_associations.order(id: :desc)
      @orders = @orders.for_regular_drivers unless current_user.certified_driver?
      paginate_orders
    else
      @orders = []
    end
    render :index
  end

  def create
    result = Orders::Create.call(buyer: current_user, params: params, ip: request.remote_ip)
    @payment_result = result.payment_result
    render_show result
  end

  def calculate
    result = Orders::Calculator.call(params: params)
    if result.success?
      @price = result.price
    else
      render_errors nil, result.errors
    end
  end

  def change_status
    @order = Order.find params[:id]
    result = Orders::ChangeStatus.call(user: current_user, order: @order, cooking_time: params[:cooking_time])
    render_show result
  end

  def cancel
    @order = Order.find params[:id]
    result = Orders::Cancel.call(user: current_user, order: @order)
    render_show result
  end

  private

  def paginate_orders
    total = @orders.count
    @orders = @orders.paginate(page_params[:page], page_params[:limit])
    pagination(@orders.current_page, @orders.limit_value, total, @orders.total_pages)
  end

  def page_params
    params.permit(:page, :limit)
  end


  def render_show result
    if result.success?
      @order = result.order
      render :show, status: :created
    else
      render_errors nil, result.errors
    end
  end

  def index_params
    params.permit(:page, filter: [:current, :status, :active, :in_progress, :sort_by_id])
  end

  def find_order
    @order = current_user.orders.find params[:id]
  end
end
