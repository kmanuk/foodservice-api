class Cancellation < ApplicationRecord
  belongs_to :order
  belongs_to :user, optional: true
  enum who: %w(seller driver system)
end

# == Schema Information
#
# Table name: cancellations
#
#  id         :integer          not null, primary key
#  who        :integer
#  reason     :string
#  status     :string
#  user_id    :integer
#  order_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_cancellations_on_order_id  (order_id)
#  index_cancellations_on_user_id   (user_id)
#
