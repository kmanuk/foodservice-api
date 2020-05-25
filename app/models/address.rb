class Address < ApplicationRecord
  reverse_geocoded_by :latitude, :longitude
  validates_presence_of :location, :latitude, :longitude

  def as_json options = {}
    options[:except] ||= []
    options[:except] += %i(created_at updated_at)
    super options
  end

  def coordinates
    [latitude, longitude]
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
