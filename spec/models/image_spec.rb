require 'rails_helper'

RSpec.describe Image, type: :model do
  describe 'macros' do
    it { is_expected.to have_attached_file(:data) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:imageable) }
  end

  describe 'validations' do
    it { is_expected.to validate_attachment_content_type(:data).allowing('image/png', 'image/gif').rejecting('text/plain', 'text/xml') }
    it { is_expected.to validate_attachment_size(:data).less_than(10.megabytes) }
  end
end

# == Schema Information
#
# Table name: images
#
#  id                :integer          not null, primary key
#  imageable_type    :string
#  imageable_id      :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  data_file_name    :string
#  data_content_type :string
#  data_file_size    :integer
#  data_updated_at   :datetime
#
# Indexes
#
#  index_images_on_imageable_type_and_imageable_id  (imageable_type,imageable_id)
#
