require 'rails_helper'

RSpec.describe CookingNotificationWorker, type: :worker do
  describe '#perform' do
    context 'if order not cooking' do
      let(:order) { create(:order) }

      it 'should return' do
        expect(Push::Generator).not_to receive(:call)
        CookingNotificationWorker.new.perform(order.id)
      end
    end

    context 'if order cooking' do
      let(:order) { create(:order, :cooking) }

      it 'should send notification' do
        expect(Push::Generator).to receive(:call).with({
          users: order.seller,
          notification: :cooking_time,
          order: order
        }).once
        CookingNotificationWorker.new.perform(order.id)
      end
    end
  end
end
