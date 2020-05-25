class Item < ApplicationRecord
  self.inheritance_column = nil

  SERVICE_FEE = 0.1

  default_scope { order('items.id ASC') }

  extend Enumerize
  include Filterable

  enumerize :type, in: %w(free live preorder), scope: true, predicates: true

  belongs_to :user
  belongs_to :product_type
  belongs_to :category
  belongs_to :sub_category

  has_one :image, as: :imageable, dependent: :nullify

  has_many :orders

  accepts_nested_attributes_for :image

  validates_presence_of :name
  validates_numericality_of :time_to_cook, greater_than: 0, if: :preorder?
  validates_inclusion_of :type, in: type.values

  scope :from_active_sellers, -> { where(user_id: User.sellers.active) }
  scope :include_image_and_filter, ->(filter) { includes(:image).filter(filter) }
  scope :preorders, -> { with_type(:preorder) }
  scope :without_user, ->(id) { where.not(user_id: id) }
  scope :with_search, ->(name) { where("items.name ilike ?", "%#{name}%") }
  scope :with_category, ->(id) { where(category_id: id) }
  scope :with_seller, ->(id) { where(user_id: id) }
  scope :with_product_type, ->(id) { where(product_type_id: id) }
  scope :with_sub_category, ->(id) { where(sub_category_id: id) }
  scope :with_type, ->(type) { where(type: type) }
  scope :with_sellers_rate, ->(rate) { where(user_id: User.sellers.joins(:reviews).having("AVG(reviews.rate) >= #{rate}").group("users.id").pluck(:id)) }

  scope :with_amount, -> { where.not(amount: 0) }

  before_save :calculate_total_price

# scope :with_sellers_rate, ->(rate) { eager_load(user: :reviews).having("AVG(reviews.rate) >= #{rate}").group('items.id, users.id, reviews.id, images.id') }

  def self.valid_filters
    %w(search category sub_category type sellers_rate location product_type seller)
  end

  def self.with_location location
    # create box from params
    box = [
        location[:bottom_left_latitude],
        location[:bottom_left_longitude],
        location[:top_right_latitude],
        location[:top_right_longitude]
    ]

    # find ids of addresses inside selected box
    ids = Address.within_bounding_box(box).pluck(:id)
    # get items with users with address ids in array
    joins(:user).where(users: {address_id: ids})
  end

  private

  def calculate_total_price
    self.total_price = (price + price * SERVICE_FEE).round(2)
  end
end

# == Schema Information
#
# Table name: items
#
#  id              :integer          not null, primary key
#  sub_category_id :integer
#  user_id         :integer
#  information     :text
#  price           :float            default("0.0")
#  amount          :integer          default("1")
#  time_to_cook    :float            default("0.0")
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  name            :string
#  product_type_id :integer
#  category_id     :integer
#  total_price     :float
#
# Indexes
#
#  index_items_on_category_id      (category_id)
#  index_items_on_product_type_id  (product_type_id)
#  index_items_on_sub_category_id  (sub_category_id)
#  index_items_on_type             (type)
#  index_items_on_user_id          (user_id)
#
