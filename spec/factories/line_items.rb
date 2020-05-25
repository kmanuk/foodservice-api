FactoryGirl.define do
  factory :line_item do
    name        { generate :food }
    price       { generate :float }
    quantity    { Faker::Number.between(1,9) }
    item_id     { create(:item).id}
  end
end

# == Schema Information
#
# Table name: line_items
#
#  id           :integer          not null, primary key
#  order_id     :integer
#  price        :decimal(8, 2)
#  quantity     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  total_price  :decimal(8, 2)
#  name         :string
#  item_id      :integer
#  time_to_cook :float            default("0.0")
#  image_url    :string
#
# Indexes
#
#  index_line_items_on_order_id  (order_id)
#
