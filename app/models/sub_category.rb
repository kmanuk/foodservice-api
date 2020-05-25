class SubCategory < ApplicationRecord
  include Translatable

  has_many :items, dependent: :destroy
  belongs_to :category

  has_one :image, as: :imageable, dependent: :nullify
  accepts_nested_attributes_for :image

  def title
    self[I18n.locale]
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
