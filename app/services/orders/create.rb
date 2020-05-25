class Orders::Create < Orders::Base
  include Interactor

  before do
    @buyer = context[:buyer]
    @params = context[:params]
    @line_items = build_line_items
    @seller = find_seller
    context.fail!(errors: I18n.t('errors.create.before')) unless order_params[:address_attributes].present?
    @address = order_params[:address_attributes]
    @payment = order_params[:payment_attributes]
    @delivery_type = order_params[:delivery_type]
    @type = order_params[:type]
  end

  def call
    result = Orders::Calculator.call(params: @params)
    if result.success?
      price_object = result.price
    else
      context.fail!(errors: result.errors)
    end

    params = {
        seller: @seller,
        buyer: @buyer,
        payment_type: order_params[:payment_type],
        line_items: @line_items,
        delivery_type: @delivery_type,
        type: @type,
        address_attributes: @address,
        price: price_object.price,
        fee_price: price_object.fee_price,
        total_price: price_object.total_price,
        service_fee: price_object.service_fee,
        delivery_price: price_object.delivery_price,
        global_price: price_object.global_price,
        distance: price_object.distance,
        duration: price_object.duration,
        polyline: price_object.polyline,
        cooking_time: calculate_cooking_time
    }


    amount_available?(params[:line_items])

    @order = Order.new params
    unless @order.save
      context.fail!(errors: @order.errors.full_messages)
    end

    if @order.all_free? || @order.cash?
      @order.update(paid: true)
      push_to_seller
      set_canceletion_job
    else
      @payment_result = charge_client
    end
  end

  after do
    context.order = @order
    context.payment_result = @payment_result
  end

  private


  def charge_client
    context.fail!(errors: I18n.t('errors.payment.no_payment_params')) unless @payment.present?
    payment_params = {
        card_number: @payment[:card_number],
        card_holder_name: @payment[:card_holder_name],
        expiry_date: @payment[:expiry_date],
        token: @payment[:token_name],
        card_bin: @payment[:card_bin],
        merchant_reference: @payment[:merchant_reference],
        order: @order,
        ip_address: context[:ip]
    }
    payment = Payment.new payment_params
    unless payment.save
      context.fail!(errors: payment.errors.full_messages)
    end

    auth_result = Payments::Authorization.call(order: @order).result

    if auth_result['response_code'] =='20064' && auth_result['3ds_url']
      payment.update(status: '3ds_required')
    elsif auth_result['response_code'].last(3) == '000'
      payment.authorized!
      push_to_seller
      set_canceletion_job
    else
      payment.failed!
    end

    auth_result
  end


  def build_line_items
    find_items do |item, quantity|
      LineItem.new(
          name: item.name,
          time_to_cook: item.time_to_cook * quantity,
          image_url: item&.image&.data&.url,
          price: item.price,
          quantity: quantity,
          item_id: item.id,
          total_price: item.total_price * quantity
      )
    end
  end

  def calculate_cooking_time
    find_items { |item, quantity| item.time_to_cook * quantity }.sum.round
  end

  def set_canceletion_job
    OrderCanceletionWorker.perform_in(1.hour, @order.id, :not_approved)
  end

  def push_to_seller
    Push::Generator.call(user: @order.seller, notification: :order_created, order: @order)
  end
end
