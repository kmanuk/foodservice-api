# Push::Generator.call(user: User.last, notification: :new_order)
# Push::Generator.call(users: User.limit(5), notification: :new_order)

class Push::Generator
  include Interactor

  attr_reader :users, :notification

  # DO NOT USE 0 VALUE!
  TYPES = {
      new_order: 1,
      driver_not_found: 2,
      not_approved: 3,
      change_status: 4,
      order_created: 5,
      canceled_by_seller: 6,
      canceled_by_driver: 7,
      cooking_time: 8
  }.freeze

  before do
    @users = Array.wrap(context[:user] ? context[:user] : context[:users])
    @notification = context[:notification]
    @order = context[:order]
  end

  def call
    return unless @order # skip if order empty

    options = build_notification
    return unless options # skip if can not find notification

    # add order information
    options.merge!({
                       custom_data: {order: {id: @order.id,
                                             type: @order.type,
                                             status: @order.status.humanize.downcase,
                                             address: @order.address.location,
                                             latitude: @order.address.latitude,
                                             longitude: @order.address.longitude},
                                     type: TYPES[notification]},
                       category: 'order'
                   })

    # send push notification
    Push::Send.call(users: users, options: options)
  end

  private

  def build_notification
    case notification
      when :new_order
        {alert: I18n.t('push_notification.new_order', address: @order.address.location)}
      when :driver_not_found
        {alert: I18n.t('push_notification.driver_not_found', id: @order.id)}
      when :not_approved
        {alert: I18n.t('push_notification.not_approved', id: @order.id)}
      when :change_status
        status = @order.status.humanize.downcase
        {alert: I18n.t('push_notification.change_status', id: @order.id, status: status)}
      when :order_created
        {alert: I18n.t('push_notification.order_created')}
      when :canceled_by_seller
        {alert: I18n.t('push_notification.canceled_by_seller', id: @order.id)}
      when :canceled_by_driver
        {alert: I18n.t('push_notification.canceled_by_driver', id: @order.id)}
      when :cooking_time
        {alert: I18n.t('push_notification.cooking_time', id: @order.id)}
    end
  end
end
