require 'google_maps_service'

# Setup global parameters
GoogleMapsService.configure do |config|
  config.key = ENV['GMAPS_KEY']
  config.retry_timeout = 10
  config.queries_per_second = 10
end
