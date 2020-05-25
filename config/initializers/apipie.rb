Apipie.configure do |config|
  config.app_name                = "FoodinHoods API"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/documentation"
  config.default_version         = "v1"
  config.validate                = false
  config.reload_controllers      = Rails.env.development?
  config.api_routes              = Rails.application.routes
  config.show_all_examples       = true

  config.api_controllers_matcher = "#{Rails.root}/app/controllers/{[!concerns/]**/*,*}.rb"
  config.app_info['v1'] = "FoodinHoods API version 1.0"

  config.authenticate = Proc.new do
    unless Rails.env.development?
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV['API_DOCUMENTATION_USER'] && password == ENV['API_DOCUMENTATION_PASSWORD']
      end
    end
  end
end
