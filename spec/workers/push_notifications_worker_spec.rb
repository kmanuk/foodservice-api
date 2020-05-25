require 'rails_helper'

RSpec.describe PushNotificationsWorker, type: :worker do
  describe '#perform' do
    let!(:user) { create(:user) }
    let(:tokens) { [user.token] }

    it 'should create user notification with params' do
      expect(Houston::Notification).to receive(:new).with({
                                                              alert: 'Hello',
                                                              device: tokens.first,
                                                              sound: 'sound.mp3',
                                                              badge: 0,
                                                              content_available: true}).once

      PushNotificationsWorker.new.perform(tokens, {'alert' => 'Hello', 'sound' => 'sound.mp3'})
    end


    it 'send notification with badge = push_count_orders + push_count_messages' do
      user.update(push_count_orders: 2, push_count_messages: 1)
      expect(Houston::Notification).to receive(:new).with({
                                                              alert: 'Hello',
                                                              device: tokens.first,
                                                              sound: 'sound.mp3',
                                                              badge: 3,
                                                              content_available: true}).once

      PushNotificationsWorker.new.perform(tokens, {'alert' => 'Hello', 'sound' => 'sound.mp3'})
    end


    it 'should add default sound' do
      expect(Houston::Notification).to receive(:new).with({
                                                              alert: 'Hello',
                                                              device: tokens.first,
                                                              sound: 'default',
                                                              badge: 0,
                                                              content_available: true
                                                          }).once

      PushNotificationsWorker.new.perform(tokens, {'alert' => 'Hello'})
    end

    it 'should send notifications' do
      allow(Houston::Notification).to receive(:new).and_return({
                                                                   alert: 'Hello',
                                                                   device: tokens.first
                                                               })

      expect(APN).to receive(:push).with([{
                                              alert: 'Hello',
                                              device: tokens.first
                                          }]).once

      PushNotificationsWorker.new.perform(tokens, {alert: 'Hello'})
    end
  end
end
