FactoryGirl.define do
  factory :order do
    association :buyer, factory: :buyer
    association :seller, factory: :seller
    association :driver, factory: :driver

    confirmed_at      {generate :date_backward}
    pickedup_at       {generate :date_backward}
    delivered_at      {generate :date_backward}
    delivery_type     'regular_driver'
    payment_type      0
    payment_id        1
    price             { generate :float }
    delivery_price    { generate :float }
    fee_price         { generate :float }
    service_fee       { generate :float }
    total_price       { generate :float }
    global_price      { generate :float }
    line_items        { build_list :line_item, 3 }
    type              'live'

    association :address, factory: :address

  end

  factory :fast_created_order, class: Order do
    to_create {|instance| instance.save(validate: false) }
    delivery_type     'regular_driver'
  end

  trait :by_cash do
    payment_type  1
    paid          true
  end

  trait :with_payment do
    after(:create) do |order|
      create(:payment, order: order)
    end
  end

  trait :with_payment_authorized do
    after(:create) do |order|
      create(:payment, order: order, status: 'authorized')
    end
  end

  trait :with_payment_paid do
    after(:create) do |order|
      create(:payment, order: order, status: 'paid')
    end
  end

  trait :with_payment_3ds_required do
    after(:create) do |order|
      create(:payment, order: order, status: '3ds_required')
    end
  end

  trait :with_payment_canceled do
    after(:create) do |order|
      create(:payment, order: order, status: 'canceled')
    end
  end

  trait :paid do
    paid      true
  end

  trait :free_order do
    type            'free'
  end

  trait :preorder do
    type            'preorder'
    cooking_time    { generate :number }
  end

  trait :self_delivery do
    delivery_type     'self_delivery'
  end

  trait :approved do
    status     'approved'
  end

  trait :canceled do
    status     'canceled'
  end

  trait :cooking do
    status     'cooking'
  end

  trait :ready do
    status     'ready'
  end

  trait :looking_for_driver do
    status     'looking_for_driver'
  end

  trait :picking_up do
    status     'picking_up'
  end

  trait :on_the_way do
    status     'on_the_way'
  end

  trait :delivered do
    status     'delivered'
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
