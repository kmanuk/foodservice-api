class Orders::Calculator < Orders::Base
  include Interactor

  attr_reader :result

  before do
    @result = OpenStruct.new
    @params = context[:params]
  end

  def call
    price = find_items { |i, q| i.price * q }.sum
    total_price = find_items { |i, q| i.total_price * q }.sum
    fee_price = total_price - price

    result.price = price.round(2)
    result.total_price = total_price.round(2)
    result.fee_price = fee_price.round(2)

    calculate_service_fee
    calculate_delivery

    result.global_price = (total_price + result.delivery_price + result.service_fee).ceil
  end

  after { context[:price] = result }

  private

  def service_fee_needed?
    !(order_params[:delivery_type] == 'self_delivery' && result.total_price.zero?)
  end

  def calculate_service_fee
    result.service_fee = service_fee_needed? ? Order::SERVICE_FEE : 0
  end

  def calculate_delivery
    case order_params[:delivery_type]
    when 0, 'self_delivery'
      result.delivery_price = 0
      result.distance = 0
      result.duration = 0
      result.polyline = ''
    when 1, 'regular_driver'
      assign_route_params
      result.delivery_price = (Order::REGULAR_DELIVERY + distance_price).round(2)
    when 2, 'certified_driver'
      assign_route_params
      result.delivery_price = (Order::CERTIFIED_DELIVERY + distance_price).round(2)
    end
  end

  def distance_price
    (result.distance.to_f / 1000).ceil * Order::KM_PRICE
  end

  def assign_route_params
    routes = build_route
    context.fail!(errors: I18n.t('errors.calculator.build_route')) if routes.blank?
    result.polyline = routes.first[:overview_polyline][:points]
    result.distance = routes.first[:legs].first[:distance][:value]
    result.duration = routes.first[:legs].first[:duration][:value]
  end

  def get_coordinates
    coordinates = [order_params.dig(:address_attributes, :latitude), order_params.dig(:address_attributes, :longitude)].compact
    context.fail!(errors: I18n.t('errors.calculator.empty_address')) if coordinates.blank?
    coordinates
  end

  def build_route
    gmaps  = GoogleMapsService::Client.new
    gmaps.directions(
      find_seller.address.coordinates,
      get_coordinates,
      alternatives: false,
      units: 'metric'
    )
  rescue GoogleMapsService::Error::ApiError => e
    context.fail!(errors: I18n.t('errors.calculator.build_route'))
  end
end
