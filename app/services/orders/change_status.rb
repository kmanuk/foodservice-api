class Orders::ChangeStatus < Orders::Base
  include Interactor

  before do
    @order = context[:order]
    @user = context[:user]
    @cooking_time = context[:cooking_time]
    @next_status = nil
  end

  def call
    send("#{@user.role}_change")
  end

  after do
    context.order = @order
  end

  private

  def seller_change
    can_change?
    validate_belongs_seller

    @next_status = @order.next_status

    if @order.pending? && @order.preorder?
      set_cooking_time
    end

    if next_status_is?(['cooking', 'ready']) && @order.pending?
      start_order
    end

    if @next_status == 'looking_for_driver'
      @order.find_driver!
    end

    update_status(@next_status)
  end

  def driver_change
    can_change?

    @next_status = @order.next_status

    if next_status_is?(%w(on_the_way picking_up delivered))
      validate_belongs_driver
    end

    if next_status_is?(['cooking', 'ready']) && @order.looking_for_driver?
      has_other_active_orders?

      @order.update(driver: @user)
      start_order
    end

    update_status(@next_status)
  end

  def buyer_change
    @next_status = if @order.self_delivery? && @order.ready?
                     'delivered'
                   else
                     nil
                   end
    update_status(@next_status)
  end

  def next_status_is?(values = [])
    ([@next_status] & values).present?
  end

  def start_order
    if @order.preorder?
      @order.update(estimation_ready: (Time.now + @order.cooking_time.minutes))
    end

    amount_available?(@order.line_items)
    reduce_amount

    Payments::Capture.call(order: @order) if @order.payment && @order.payment.authorized?
  end

  def set_cooking_time
    if @cooking_time
      @order.update(cooking_time: @cooking_time.to_i)
      CookingNotificationWorker.perform_in(@cooking_time.to_i.minutes, @order.id)
    end
  end

  def update_status(status)
    if status
      @order.update(status: status)
      Push::Generator.call(users: @order.members(exclude: @user.id), notification: :change_status, order: @order)
    else
      context.fail!(errors: I18n.t('errors.change_status.update_status'))
    end
  end

  def can_change?
    context.fail!(errors: I18n.t('errors.change_status.update_status')) unless @order.who_can_change == @user.role
  end

  def reduce_amount
    @order.line_items.map do |li|
      item = find_item(li[:item_id])
      new_amount = item.amount - li.quantity
      item.update(amount: new_amount)
    end
  end

  def has_other_active_orders?
    if @user.has_active_orders?()
      context.fail!(errors: I18n.t('errors.change_status.you_have_active_orders'))
    end
  end

end
