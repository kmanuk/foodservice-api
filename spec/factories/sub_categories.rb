FactoryGirl.define do
  factory :sub_category do
    category
    en { generate :word }
    ar { generate :word }
    description { generate :text }

    after(:create) do |sub_category|
      create(:image, imageable: sub_category)
    end
  end
end


# == Schema Information
#
# Table name: sub_categories
#
#  id          :integer          not null, primary key
#  en          :string
#  description :string
#  ar          :string
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_sub_categories_on_category_id  (category_id)
#
