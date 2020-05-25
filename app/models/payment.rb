class Payment < ApplicationRecord
  belongs_to :order

  enum status: %w(unpaid 3ds_required authorized paid canceled failed)

  scope :paid_only, -> { where(status: %w(authorized paid)) }
end

# == Schema Information
#
# Table name: payments
#
#  id                 :integer          not null, primary key
#  token              :string
#  card_number        :string
#  expiry_date        :string
#  card_bin           :string
#  card_holder_name   :string
#  remember           :string
#  order_id           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  merchant_reference :string
#  status             :integer          default("0")
#  ip_address         :string
#
# Indexes
#
#  index_payments_on_order_id  (order_id)
#
