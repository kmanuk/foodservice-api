class DriverFinderWorker
  include Sidekiq::Worker
  include Sidekiq::Symbols
  sidekiq_options queue: 'driver-finder', retry: false

  def perform order_id, distance:, except_distance: nil, certified:
    order = Order.find(order_id)
    return if order.driver_id

    Drivers::Finder.call(order: order, distance: distance, except_distance: except_distance, certified: certified)
  end
end
