class CookingNotificationWorker
  include Sidekiq::Worker
  include Sidekiq::Symbols
  sidekiq_options queue: 'notification', retry: false

  def perform order_id
    order = Order.find(order_id)
    return unless order.cooking?

    Push::Generator.call(users: order.seller, notification: :cooking_time, order: order)
  end
end
