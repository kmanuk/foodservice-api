require 'sidekiq/web'
require 'sidekiq/cron/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
end unless Rails.env.development?

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_HOST"], password: ENV["REDIS_PASSWORD"], namespace: "fnh-#{Rails.env}" }
  config.error_handlers << proc { |ex,context| Airbrake.notify_or_ignore(ex, parameters: context) }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_HOST"], password: ENV["REDIS_PASSWORD"], namespace: "fnh-#{Rails.env}" }
end
