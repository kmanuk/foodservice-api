require 'rails_helper'

RSpec.describe ApnTokenCleanerWorker, type: :worker do
  describe '#perform' do
    context 'without devices' do
      it 'should return' do
        allow(APN).to receive(:devices).and_return([])

        expect(User).not_to receive(:where)
        expect(User).not_to receive(:update_all)

        ApnTokenCleanerWorker.new.perform
      end
    end

    context 'with devices' do
      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }

      it 'should clear tokens for users' do
        allow(APN).to receive(:devices).and_return([user1.token, '12345678'])
        ApnTokenCleanerWorker.new.perform

        expect(user1.reload.token).to be nil
        expect(user2.reload.token).not_to be nil
      end
    end
  end
end
