class PushNotificationsWorker
  include Sidekiq::Worker
  include Sidekiq::Symbols
  sidekiq_options queue: 'push-notification', retry: false

  def perform tokens, options
    options.deep_symbolize_keys!
    options[:sound] ||= 'default'
    options[:content_available] = true

    notifications = tokens.map do |token|
      user = User.find_by(token: token)
      Houston::Notification.new(options.merge(device: token, badge: user.push_count))
    end

    APN.push(notifications)
  end
end
