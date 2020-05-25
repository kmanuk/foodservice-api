class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  reverse_geocoded_by :latitude, :longitude

  has_many :reviews, as: :ratable, dependent: :nullify
  has_many :reviews_written, class_name: 'Review', foreign_key: :reviewer_id

  ROLES_OPTIONS = %w(seller buyer driver)

  include DeviseTokenAuth::Concerns::User

  enum role: ROLES_OPTIONS

  belongs_to :address, dependent: :destroy, optional: true
  accepts_nested_attributes_for :address

  has_many :driver_orders, class_name: 'Order', foreign_key: :driver_id
  has_many :seller_orders, class_name: 'Order', foreign_key: :seller_id
  has_many :buyer_orders, class_name: 'Order', foreign_key: :buyer_id
  has_many :items, dependent: :destroy
  has_many :cancellations

  validates_inclusion_of :role, in: ROLES_OPTIONS, allow_nil: true
  validate :active_orders

  validates_presence_of :name
  validates_uniqueness_of :uid, scope: :provider, case_sensitive: false

  # validates_presence_of :phone, :car_type, :plate_number, :driver_license, :insurance_name, :insurance_number, if: :driver?

  has_attached_file :avatar, default_url: '', styles: {thumb: "300x300>"}
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  validates_attachment_size :avatar, less_than: 10.megabytes

  has_attached_file :video_snapshot, default_url: '', styles: {thumb: "300x300>"}
  validates_attachment_content_type :video_snapshot, content_type: /\Aimage\/.*\z/
  validates_attachment_size :video_snapshot, less_than: 10.megabytes

  has_attached_file :video, default_url: ''
  validates_attachment_content_type :video, content_type: /\Avideo\/.*\z/
  validates_attachment_size :video, less_than: 100.megabytes

  before_avatar_post_process :rename_avatar
  before_video_post_process :rename_video
  before_video_snapshot_post_process :rename_video_snapshot


  scope :drivers, -> { where(role: 'driver', approved_driver: true) }
  scope :sellers, -> { where(role: 'seller') }
  scope :buyers, -> { where(role: 'buyer') }
  scope :regular_drivers, -> { where(certified_driver: false) }
  scope :certified_drivers, -> { where(certified_driver: true) }
  scope :active, -> { where(active: true) }
  scope :with_active_orders, ->(role) { includes("#{role}_orders").where(orders: {status: [0, 2, 3, 4, 5, 6]})}

  before_save :set_locale

  before_destroy do
    errors.add :base, 'User has orders' unless orders.count == 0
    throw(:abort) if errors.present?
  end

  def inactive!
    update(active: false, active_driver: false)
  end

  def remove_push_token
    update(token: nil)
  end

  def avatar_url
    avatar&.url
  end

  def avatar_thumb
    avatar&.url(:medium)
  end

  def video_snapshot_url
    video_snapshot&.url
  end

  def video_snapshot_thumb
    video_snapshot&.url(:medium)
  end

  def video_url
    video&.url
  end

  def reset_push_counter (param = nil)
    if param
      update(param => 0)
    else
      update(push_count_messages: 0, push_count_orders: 0)
    end
  end

  def push_count
    push_count_messages + push_count_orders
  end

  def send_password_change_notification options = {}
    send_devise_notification(:password_change, options)
  end

  def as_json options = {}
    options[:except] ||= []
    options[:except] += %i(avatar_file_name address_id avatar_content_type avatar_file_size avatar_updated_at created_at updated_at video_file_name video_content_type video_file_size video_updated_at video_snapshot_file_name video_snapshot_content_type video_snapshot_file_size video_snapshot_updated_at)

    options[:methods] ||= []
    options[:methods] += %i(avatar_url avatar_thumb video_snapshot_url video_snapshot_thumb video_url )

    options[:include] = {address: {except: %i(created_at updated_at)}}

    super options
  end

  def address_params
    address.as_json
  end

  def find_preorder_item
    items.with_type('preorder').first
  end

  def orders r = nil
    case r || role
      when 'seller'
        seller_orders
      when 'driver'
        driver_orders
      else
        buyer_orders
    end
  end

  def av_rate
    reviews.present? ? reviews.average(:rate).to_f : nil
  end

  def has_active_orders? role = nil
    orders(role).active.paid_only.exists?
  end

  def online_driver?
    driver? && active_driver? && approved_driver?
  end

  private

  def rename_avatar
    extension = File.extname(avatar_file_name).downcase
    self.avatar.instance_write :file_name, "#{SecureRandom.hex}#{extension}"
  end

  def rename_video_snapshot
    extension = File.extname(video_snapshot_file_name).downcase
    self.video_snapshot.instance_write :file_name, "#{SecureRandom.hex}#{extension}"
  end


  def rename_video
    extension = File.extname(video_file_name).downcase
    self.video.instance_write :file_name, "#{SecureRandom.hex}#{extension}"
  end

  def set_locale
    self.locale = I18n.locale
  end

  def active_orders
    if role_changed? && has_active_orders?(role_was)
      errors.add(:role, I18n.t('errors.role.active_orders'))
    end
  end

  def send_devise_notification notification, *args
    devise_mailer.delay(queue: 'devise-mailer').send(notification, self, *args)
  end
end

# == Schema Information
#
# Table name: users
#
#  id                          :integer          not null, primary key
#  provider                    :string           default("email"), not null
#  uid                         :string           default(""), not null
#  encrypted_password          :string           default(""), not null
#  reset_password_token        :string
#  reset_password_sent_at      :datetime
#  remember_created_at         :datetime
#  sign_in_count               :integer          default("0"), not null
#  current_sign_in_at          :datetime
#  last_sign_in_at             :datetime
#  current_sign_in_ip          :string
#  last_sign_in_ip             :string
#  confirmation_token          :string
#  confirmed_at                :datetime
#  confirmation_sent_at        :datetime
#  unconfirmed_email           :string
#  phone                       :string
#  email                       :string
#  tokens                      :json
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  avatar_file_name            :string
#  avatar_content_type         :string
#  avatar_file_size            :integer
#  avatar_updated_at           :datetime
#  token                       :string
#  role                        :integer
#  address_id                  :integer
#  recommended_seller          :boolean          default("false")
#  approved_driver             :boolean          default("false")
#  certified_driver            :boolean          default("false")
#  video_file_name             :string
#  video_content_type          :string
#  video_file_size             :integer
#  video_updated_at            :datetime
#  locale                      :string
#  quickblox_user_id           :integer
#  latitude                    :float
#  longitude                   :float
#  name                        :string
#  active                      :boolean          default("true")
#  video_snapshot_file_name    :string
#  video_snapshot_content_type :string
#  video_snapshot_file_size    :integer
#  video_snapshot_updated_at   :datetime
#  business_name               :string
#  active_driver               :boolean          default("true")
#  iban                        :string
#  bank_name                   :string
#  car_type                    :string
#  plate_number                :string
#  driver_license              :string
#  insurance_name              :string
#  insurance_number            :string
#  push_count_messages         :integer          default("0")
#  push_count_orders           :integer          default("0")
#
# Indexes
#
#  index_users_on_address_id            (address_id)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email)
#  index_users_on_latitude              (latitude)
#  index_users_on_longitude             (longitude)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role                  (role)
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
