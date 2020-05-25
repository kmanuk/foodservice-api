FactoryGirl.define do
  factory :address do
    location  '58/10 Gaydara, Kiev ,Ukraine'
    latitude  50.434369
    longitude 30.501461
  end

  factory :address_germany, class: Address do
    location  '60313 Frankfurt am Main, Germany'
    latitude 50.114303
    longitude 8.676896
  end


end



# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  latitude   :float
#  longitude  :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  location   :string
#
# Indexes
#
#  index_addresses_on_latitude   (latitude)
#  index_addresses_on_longitude  (longitude)
#
