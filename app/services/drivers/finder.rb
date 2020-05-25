# Drivers::Finder(order: User.last, certified: true, distance: 99, except_distance: 10)

class Drivers::Finder
  include Interactor

  attr_accessor :drivers
  attr_reader :order, :distance, :except_distance, :certified, :address

  before do
    @order = context[:order]
    @distance = context[:distance]
    @certified = context[:certified]
    @except_distance = context[:except_distance]
  end

  before do
    @address = @order.seller&.address&.location
  end

  def call
    return unless address

    scope = build_scope
    except_ids = get_except_ids(scope)
    drivers = scope.near(address, distance).where.not(id: except_ids)

    Push::Generator.call(users: drivers, notification: :new_order, order: @order)

    context[:drivers] = drivers
  end

  private

  def build_scope
    scope = User.drivers.where(active_driver: true)
    scope = exclude_drivers_with_active_orders scope
    scope = scope.certified_drivers if certified
    scope
  end

  def get_except_ids scope
    return [] unless except_distance
    return scope.near(address, except_distance, order: '').ids
  end

  def exclude_drivers_with_active_orders scope
    except_ids = scope.with_active_orders('driver').ids
    scope.where.not(id: except_ids)
  end


end
