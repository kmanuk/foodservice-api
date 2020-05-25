class OrderCanceletionWorker
  include Sidekiq::Worker
  include Sidekiq::Symbols
  sidekiq_options queue: 'order-canceletion', retry: false

  def perform order_id, reason
    order = Order.find(order_id)

    case reason.to_sym
      when :not_approved
        return if order.canceled? || !order.pending? # skip if status was changed or order canceled
        CancellationService.call(order: order, who: 'system', reason: 'Not approved by seller')
        order.cancel!
        Payments::CancelAuthorization.call(order: order) if order&.payment&.authorized?
        Push::Generator.call(users: [order.seller, order.buyer], notification: :not_approved, order: order)
      when :system
        return if order.driver_id || order.canceled? # skip if we found driver or order canceled
        order.cancel!
        CancellationService.call(order: order, who: 'system', reason: 'Driver not found')
        Payments::CancelAuthorization.call(order: order) if order&.payment&.authorized?
        Push::Generator.call(users: [order.seller, order.buyer], notification: :driver_not_found, order: order)
    end
  end
  
end
