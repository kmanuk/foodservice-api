class Review < ApplicationRecord
  belongs_to :ratable, polymorphic: true, optional: true
  belongs_to :reviewer, class_name: 'User'
  belongs_to :order

  validates_presence_of :ratable
  validates_presence_of :reviewer
  validates_numericality_of :rate, greater_than_or_equal_to: 0, less_than_or_equal_to: 5

end

# == Schema Information
#
# Table name: reviews
#
#  id           :integer          not null, primary key
#  rate         :float
#  message      :string
#  ratable_type :string
#  ratable_id   :integer
#  reviewer_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  status       :string
#  order_id     :integer
#
# Indexes
#
#  index_reviews_on_order_id                     (order_id)
#  index_reviews_on_ratable_type_and_ratable_id  (ratable_type,ratable_id)
#  index_reviews_on_reviewer_id                  (reviewer_id)
#
