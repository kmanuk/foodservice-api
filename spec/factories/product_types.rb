FactoryGirl.define do
  factory :product_type do
    en { generate :word }
    ar { generate :word }
  end
end

# == Schema Information
#
# Table name: product_types
#
#  id         :integer          not null, primary key
#  en         :string
#  ar         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
