FactoryGirl.define do
  factory :review do
    order
    rate         Faker::Number.between(0, 5)
    message      { generate :text }
    association :reviewer, factory: :buyer
    association :ratable, factory: :seller

    trait :five_rate do
      rate       5
    end

    trait :of_seller do
      association :ratable, factory: :seller
    end

    trait :of_buyer do
      association :ratable, factory: :buyer
    end

    trait :of_driver do
      association :ratable, factory: :driver
    end

    trait :by_driver do
      association :reviewer, factory: :driver
    end

    trait :by_buyer do
      association :reviewer, factory: :buyer
    end

    trait :by_seller do
      association :reviewer, factory: :seller
    end
  end
end

# == Schema Information
#
# Table name: reviews
#
#  id           :integer          not null, primary key
#  rate         :float
#  message      :string
#  ratable_type :string
#  ratable_id   :integer
#  reviewer_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  status       :string
#  order_id     :integer
#
# Indexes
#
#  index_reviews_on_order_id                     (order_id)
#  index_reviews_on_ratable_type_and_ratable_id  (ratable_type,ratable_id)
#  index_reviews_on_reviewer_id                  (reviewer_id)
#
