### This patch added ability to get raw response from third-party services. JSON response can be used for rspec stub.


## Twitter request
# module Twitter
#   module REST
#     module Utils
#       def perform_request_with_object(request_method, path, options, klass)
#         response = perform_request(request_method, path, options)
#         klass.new(response)
#       end
#     end
#   end
# end

## Gmaps directions request
# module GoogleMapsService::Apis::Directions
#   def directions(origin, destination,
#       mode: nil, waypoints: nil, alternatives: false, avoid: nil,
#       language: nil, units: nil, region: nil, departure_time: nil,
#       arrival_time: nil, optimize_waypoints: false, transit_mode: nil,
#       transit_routing_preference: nil)
#
#     params = {
#       origin: GoogleMapsService::Convert.waypoint(origin),
#       destination: GoogleMapsService::Convert.waypoint(destination)
#     }
#
#     params[:mode] = GoogleMapsService::Validator.travel_mode(mode) if mode
#
#     if waypoints = waypoints
#       waypoints = GoogleMapsService::Convert.as_list(waypoints)
#       waypoints = waypoints.map { |waypoint| GoogleMapsService::Convert.waypoint(waypoint) }
#       waypoints = ['optimize:true'] + waypoints if optimize_waypoints
#
#       params[:waypoints] = GoogleMapsService::Convert.join_list("|", waypoints)
#     end
#
#     params[:alternatives] = 'true' if alternatives
#     params[:avoid] = GoogleMapsService::Convert.join_list('|', avoid) if avoid
#     params[:language] = language if language
#     params[:units] = units if units
#     params[:region] = region if region
#     params[:departure_time] = GoogleMapsService::Convert.time(departure_time) if departure_time
#     params[:arrival_time] = GoogleMapsService::Convert.time(arrival_time) if arrival_time
#
#     if departure_time and arrival_time
#       raise ArgumentError, 'Should not specify both departure_time and arrival_time.'
#     end
#
#     params[:transit_mode] = GoogleMapsService::Convert.join_list("|", transit_mode) if transit_mode
#     params[:transit_routing_preference] = transit_routing_preference if transit_routing_preference
#
#     return get('/maps/api/directions/json', params)[:routes]
#   end
# end
