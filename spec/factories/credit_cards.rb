FactoryGirl.define do
  factory :credit_card do
    token                  { generate :token }
    card_number            { generate :credit_card_number_masked }
    expiry_date            Faker::Number.number(4)
    card_bin               Faker::Number.number(6)
    card_holder_name       { generate :name }
    remember               'YES'
    status                 '18'
    merchant_reference     {generate :merchant_reference}
  end
end

# == Schema Information
#
# Table name: credit_cards
#
#  id                 :integer          not null, primary key
#  token              :string
#  card_number        :string
#  expiry_date        :string
#  card_bin           :string
#  card_holder_name   :string
#  remember           :string
#  status             :string
#  merchant_reference :string
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_credit_cards_on_user_id  (user_id)
#
