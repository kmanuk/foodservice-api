require 'rails_helper'

RSpec.describe Review, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to(:ratable) }
    it { is_expected.to belong_to(:reviewer) }
    it { is_expected.to belong_to(:order) }
  end

  describe 'validations' do
    it { is_expected.to respond_to(:id) }
    it { is_expected.to respond_to(:reviewer_id) }
    it { is_expected.to respond_to(:ratable_id) }
    it { is_expected.to respond_to(:ratable_type) }
    it { is_expected.to respond_to(:rate) }
    it { is_expected.to respond_to(:message) }

    it { is_expected.to validate_presence_of(:ratable) }
    it { is_expected.to validate_presence_of(:reviewer) }
    it { is_expected.to allow_values(0,1.1,2,3.0,4.9,5.0).for(:rate) }
    it { is_expected.to validate_numericality_of(:rate).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(5) }
  end
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
