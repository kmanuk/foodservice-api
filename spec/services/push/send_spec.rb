require 'rails_helper'

RSpec.describe Push::Send do
  describe '.call' do
    before { allow(Push::Send).to receive(:call).and_call_original }
    let!(:users) { create_list(:user, 4) }
    let!(:user) { users.first }


    context 'with user attribute' do
      it 'should call notification worker' do
        expect(PushNotificationsWorker).to receive(:perform_async).with(
            [user.token], {'alert' => 'Hello'}
        ).once

        Push::Send.call(user: user, options: {alert: 'Hello'})
      end

      context 'for orders category' do
        it 'should change push_count_orders by 1' do
          expect { Push::Send.call(user: user, options: {alert: 'Hello', category: 'order'}) }.to change(user, :push_count_orders)
        end
      end

      context 'for messages category' do
        it 'should change push_count_messages by 1' do
          expect { Push::Send.call(user: user, options: {alert: 'Hello', category: 'msg'}) }.to change(user, :push_count_messages)
        end
      end

    end

    context 'with users attributes' do

      it 'should call notification worker when 1 user' do
        expect(PushNotificationsWorker).to receive(:perform_async).with(
            [user.token], {'alert' => 'Hello'}
        ).once

        Push::Send.call(users: user, options: {alert: 'Hello'})
      end

      it 'should call notification worker when few user' do
        expect(PushNotificationsWorker).to receive(:perform_async).with(
            users.pluck(:token), {'alert' => 'Hello'}
        ).once
        Push::Send.call(users: users, options: {alert: 'Hello'})
      end

      it 'should change push_count for each user' do
        expect { Push::Send.call(users: users, options: {alert: 'Hello', category: 'order'}) }.to change { User.pluck(:push_count_orders) }.by([1, 1, 1, 1])
      end

      it 'should change push_count for each user' do
        expect { Push::Send.call(users: users, options: {alert: 'Hello', category: 'msg'}) }.to change { User.pluck(:push_count_messages) }.by([1, 1, 1, 1])
      end

    end

    context 'if cannot find tokens' do
      it 'should return' do
        expect(PushNotificationsWorker).not_to receive(:perform_async)
        user.update(token: nil)
        Push::Send.call(users: user, options: {alert: 'Hello'})
      end

      it 'should remove empty tokens from request' do
        users.first(3).each { |u| u.update(token: nil) }
        expect(PushNotificationsWorker).to receive(:perform_async).with(
            [users.last.token], {'alert' => 'Hello'}
        )
        Push::Send.call(users: users, options: {alert: 'Hello'})
      end
    end
  end
end
