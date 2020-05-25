# Push::Send.call(user: User.last, options: { alert: 'Hello, World!' })
# Push::Send.call(users: User.limit(5), options: { alert: 'Hello, World!' })

# Available options:
# alert: "Hello, World!"
# badge: 57
# sound: "sosumi.aiff"
# category: "INVITE_CATEGORY"
# content_available: true
# mutable_content: true
# custom_data: { foo: "bar" }

class Push::Send
  include Interactor

  attr_reader :users, :options

  before do
    @users = Array.wrap(context[:user] ? context[:user] : context[:users])
    @options = context[:options].to_h.deep_stringify_keys
  end

  def call
    tokens = users.map(&:token).reject(&:blank?).compact
    increment_push_count(@users)
    PushNotificationsWorker.perform_async(tokens, options) if tokens.present?
  end

  private

  def increment_push_count(users)
    field = @options['category'] == 'order' ? :push_count_orders : :push_count_messages
    users.each { |u| u.increment!(field) }
  end
end
