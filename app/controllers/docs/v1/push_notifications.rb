module Docs::V1::PushNotifications
  extend Apipie::DSL::Concern

  api! 'Send push notification'
  param :user_id, Integer, required: true
  param :order_id, Integer, required: true
  param :notification, Hash, required: true do
    param :alert, String, 'Text for push notification', required: true
    param :badge, Integer
    param :sound, String
    param :category, String
    param :content_available, [true, false]
    param :mutable_content, [true, false]
    param :custom_data, Hash, "Now we are using these types: #{Push::Generator::TYPES.to_s}"
  end
  def index; end

  api! 'Reset push counter for user'
  param :type, %w(push_count_orders push_count_messages)
  def reset; end

end
