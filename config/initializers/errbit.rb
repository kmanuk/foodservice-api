Airbrake.configure do |config|
  config.host = 'http://ex.ctdev.io'
  config.project_id = 1 # required, but any positive integer works
  config.project_key = '3221deb6bfd00a7e8e9882418abdbca1'
  config.environment = Rails.env
  config.ignore_environments = %w(development test)
end