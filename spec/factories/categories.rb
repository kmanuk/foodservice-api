FactoryGirl.define do
  factory :category do
    product_type

    en { generate :word }
    ar { generate :word }
    description { generate :text }

    after(:create) do |category|
      create(:image, imageable: category)
    end
  end

  trait :with_sub_categories do
    after(:create) do |category|
      create_list(:sub_category, 3, category: category)
    end
  end
end

# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  en              :string
#  description     :string
#  ar              :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  product_type_id :integer
#
# Indexes
#
#  index_categories_on_product_type_id  (product_type_id)
#
