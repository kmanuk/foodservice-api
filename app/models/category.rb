class Category < ApplicationRecord
  include Translatable

  has_many :sub_categories, dependent: :destroy
  belongs_to :product_type

  has_one :image, as: :imageable, dependent: :nullify
  accepts_nested_attributes_for :image

  def title
    self[I18n.locale]
  end

end

# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  en              :string
#  description     :string
#  ar              :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  product_type_id :integer
#
# Indexes
#
#  index_categories_on_product_type_id  (product_type_id)
#
