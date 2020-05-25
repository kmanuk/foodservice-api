require 'rails_helper'

RSpec.describe Cancellation, type: :model do
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
