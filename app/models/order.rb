class Order < ApplicationRecord
  self.inheritance_column = nil

  DISTANCE_RANGE = [10, 30, 100]
  REGULAR_DELIVERY = 3
  CERTIFIED_DELIVERY = 5
  SERVICE_FEE = 2
  KM_PRICE = 0.6

#  extend Enumerize
  include Filterable

  belongs_to :address, dependent: :destroy
  belongs_to :driver, class_name: 'User', optional: true
  belongs_to :seller, class_name: 'User'
  belongs_to :buyer, class_name: 'User'

  accepts_nested_attributes_for :address

  enum type: %w(free live preorder)
  enum payment_type: %w(card cash)
  enum delivery_type: %w(self_delivery regular_driver certified_driver)

  has_many :line_items, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_many :cancellations

  enum status: %w(pending canceled looking_for_driver cooking ready picking_up on_the_way delivered)

  validates_presence_of :status
  validates_presence_of :seller_id
  validates_presence_of :buyer_id
  validates_presence_of :line_items

  validates_presence_of :type
  validates_presence_of :delivery_type

  scope :with_current, ->(param) { where.has { created_at > 1.day.ago } }
  scope :with_status, ->(param) { where(status: param) }
  scope :with_active, ->(param) { where.not(status: [:pending, :canceled, :delivered]) }
  scope :active, -> { where.not(status: [:canceled, :delivered]) }
  scope :with_in_progress, -> { where.not(status: [:canceled, :pending, :delivered]) }
  scope :looking_driver, -> { where(status: :looking_for_driver) }
  scope :for_certified_drivers, -> { where(delivery_type: 'certified_driver') }
  scope :for_regular_drivers, -> { where(delivery_type: 'regular_driver') }
  scope :with_associations, -> { includes(:address, :line_items, :seller, :driver, :buyer, :reviews) }
  scope :paid_only, -> { where(id: Payment.paid_only.pluck(:order_id)).or(cash) }
  scope :with_sort_by_id, ->(param) { order(id: param) }

  def self.valid_filters
    %w(current status active in_progress sort_by_id)
  end

  def members exclude: nil
    users = [seller, buyer, driver].compact
    users.reject! { |u| u.id == exclude } if exclude
    users
  end

  def linked_with? user_id
    buyer_id == user_id ||seller_id == user_id ||driver_id == user_id
  end

  def cancel!
    update(status: :canceled)
  end

  def review_added?
    reviews.any? { |r| r.status == 'seller' }
  end

  def all_free?
    free? && self_delivery?
  end

  def possible_statuses
    exclude = case type
                when 'preorder'
                  self_delivery? ? %w(looking_for_driver picking_up on_the_way) : []
                else
                  self_delivery? ? %w(cooking looking_for_driver picking_up on_the_way) : %w(cooking)
              end

    Order.statuses.keys - exclude - ['canceled']
  end

  def possible_statuses_with_cancel
    possible_statuses + ['canceled']
  end


  def next_status
    canceled? ? nil : possible_statuses[possible_statuses.find_index(status) + 1]
  end

  def who_can_change
    case status
      when 'pending', 'cooking'
        'seller'
      when 'looking_for_driver', 'picking_up', 'on_the_way'
        'driver'
      when 'ready'
        self_delivery? ? 'buyer' : 'driver'
      else
        nil
    end
  end

  def who_can_cancel
    case status
      when 'pending', 'looking_for_driver'
        ['seller']
      when 'cooking', 'ready'
        %w(seller driver)
      else
        nil
    end
  end

# order.find_driver! with_canceletion: false
# Arguments:
# with_canceletion: bool => cancel order if can not find driver
  def find_driver! with_canceletion: true
    return if self_delivery?
    delay = 0

    # create jobs for each distance with delay
    DISTANCE_RANGE.each_with_previous do |previous, current|
      DriverFinderWorker.perform_in(delay.minutes, id, certified: certified_driver?, distance: current, except_distance: previous)
      delay += 2
    end

    # create canceletion job
    if with_canceletion
      OrderCanceletionWorker.perform_in(delay.minutes, id, :system)
    end
  end
end

# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  buyer_id         :integer
#  seller_id        :integer
#  driver_id        :integer
#  status           :integer          default("0"), not null
#  confirmed_at     :datetime
#  pickedup_at      :datetime
#  delivered_at     :datetime
#  delivery_type    :integer
#  payment_type     :integer
#  payment_id       :integer
#  price            :float
#  delivery_price   :float
#  fee_price        :float
#  address_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  type             :integer
#  distance         :integer          default("0")
#  duration         :integer          default("0")
#  polyline         :text             default("")
#  delivery_steps   :jsonb            default("{}"), not null
#  cooking_time     :integer
#  estimation_ready :datetime
#  service_fee      :float
#  paid             :boolean          default("false")
#  total_price      :float
#  global_price     :float
#
# Indexes
#
#  index_orders_on_address_id  (address_id)
#  index_orders_on_buyer_id    (buyer_id)
#  index_orders_on_driver_id   (driver_id)
#  index_orders_on_seller_id   (seller_id)
#
