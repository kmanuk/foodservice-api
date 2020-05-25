FactoryGirl.define do
  factory :item do
    product_type
    category
    sub_category
    association :user, factory: :seller
    name               { generate :food }
    information        { generate :text }
    price              { generate :float }
    amount             { Faker::Number.between(10,20) }
    type               'live'

    after(:create) do |item|
      create(:image, imageable: item)
    end
  end


  factory :fast_created_item, class: Item do
    to_create {|instance| instance.save(validate: false) }
  end

  trait :free_item do
    type            'free'
    price           0
  end

  trait :preorder_item do
    type            'preorder'
    time_to_cook       { generate :float }
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
