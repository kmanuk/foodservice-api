FactoryGirl.define do
  factory :payment do
    token                { generate :token }
    card_number          { generate :credit_card_number_masked }
    expiry_date          Faker::Number.number(4)
    card_bin             Faker::Number.number(6)
    card_holder_name     { generate :name }
    remember             'YES'
    association :order, factory: :order
    merchant_reference   {generate :merchant_reference}

    trait :secure_required do
      status             '3ds_required'
    end

    trait :authorized do
      status             'authorized'
    end

    trait :paid do
      status             'paid'
    end


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
