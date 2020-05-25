class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true, optional: true

  has_attached_file :data, default_url: '', styles: lambda { |i| i.instance.styles }
  validates_attachment_content_type :data, content_type: /\Aimage\/.*\z/
  validates_attachment_size :data, less_than: 10.megabytes

  before_post_process :rename_file

  def styles
    if imageable.instance_of? Item
      { thumb: "800x800>" }
    else
      {}
    end
  end

  private

  def rename_file
    extension = File.extname(data_file_name).downcase
    self.data.instance_write :file_name, "#{SecureRandom.hex}#{extension}"
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
