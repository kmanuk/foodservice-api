require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:order) }
  end
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
