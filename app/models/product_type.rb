class ProductType < ApplicationRecord
  include Translatable

  has_many :categories, dependent: :destroy

  has_one :image, as: :imageable, dependent: :nullify
  accepts_nested_attributes_for :image

  def title
    self[I18n.locale]
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
