class Orders::Cancel < Orders::Base
  include Interactor

  before do
    @order = context[:order]
    @user = context[:user]
  end

  def call
    if @user.seller?

      validate_belongs_seller
      can_cancel?

      increase_amount unless current_status_is?(%w(pending looking_for_driver))

      CancellationService.call(order: @order, who: 'seller')
      @order.cancel!


      Payments::CancelAuthorization.call(order: @order) if @order&.payment&.authorized?

      Push::Generator.call(
          users: [@order.buyer, @order.driver].compact,
          notification: :canceled_by_seller,
          order: @order
      )
    elsif @user.driver?
      validate_belongs_driver
      can_cancel?
      increase_amount

      CancellationService.call(order: @order, who: 'driver')

      @order.update({status: :looking_for_driver, driver: nil})
      @order.find_driver! with_canceletion: false

      Push::Generator.call(
          users: [@order.seller, @order.buyer],
          notification: :canceled_by_driver,
          order: @order
      )
    else
      context.fail!(errors: I18n.t('errors.cancel.call'))
    end
  end

  after do
    context.order = @order
  end

  private

  def increase_amount
    @order.line_items.map do |li|
      item = find_item(li[:item_id])
      new_amount = item.amount + li.quantity
      item.update(amount: new_amount)
    end
  end

  def current_status_is?(values = [])
    ([@order.status] & values).present?
  end

  def can_cancel?
    context.fail!(errors: I18n.t('errors.cancel.cannot_cancel')) unless @order.who_can_cancel && @order.who_can_cancel.include?(@user.role)
  end


end
