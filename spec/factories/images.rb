FactoryGirl.define do
  factory :image do
    data { generate :file }
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
