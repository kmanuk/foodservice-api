require 'rails_helper'

RSpec.describe Address, type: :model do

  describe 'validations' do
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:latitude) }
    it { is_expected.to validate_presence_of(:longitude) }
  end

  describe '#coordinates' do
    it 'should return array with coordinates' do
      address = build(:address)
      expect(address.coordinates).to eq [address.latitude, address.longitude]
    end
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
