require 'rails_helper'

RSpec.describe Push::Generator do
  describe '.call' do
    before { allow(Push::Generator).to receive(:call).and_call_original }

    let!(:user) { create(:user) }
    let!(:user2) { create(:user) }
    let(:order) { create(:order) }

    def expect_push_send(notification, options, users = nil)
      users ||= [user]
      expect(Push::Send).to receive(:call).with({
                                                    users: users,
                                                    options: options.merge(
                                                        custom_data: {order: {id: order.id,
                                                                              type: order.type,
                                                                              status: order.status,
                                                                              address: order.address.location,
                                                                              latitude: order.address.latitude,
                                                                              longitude: order.address.longitude},
                                                                      type: Push::Generator::TYPES[notification]
                                                        },
                                                        category: 'order'
                                                    )
                                                })
    end

    it 'should not use 0 type' do
      # Additional check for 0 value
      expect(Push::Generator::TYPES.values).not_to include(0)
    end

    it 'should set TYPES constant' do
      expect(Push::Generator::TYPES).to eq({
                                               new_order: 1,
                                               driver_not_found: 2,
                                               not_approved: 3,
                                               change_status: 4,
                                               order_created: 5,
                                               canceled_by_seller: 6,
                                               canceled_by_driver: 7,
                                               cooking_time: 8
                                           })
    end

    it 'should create new order notification' do
      expect_push_send(:new_order, {
          alert: I18n.t('push_notification.new_order', address: order.address.location)
      })
      Push::Generator.call(user: user, notification: :new_order, order: order)
    end

    it 'should create order not approved notification' do
      expect_push_send(:not_approved, {
          alert: I18n.t('push_notification.not_approved', id: order.id)
      })
      Push::Generator.call(user: user, notification: :not_approved, order: order)
    end

    it 'should create driver not found notification' do
      expect_push_send(:driver_not_found, {
          alert: I18n.t('push_notification.driver_not_found', id: order.id)
      })
      Push::Generator.call(user: user, notification: :driver_not_found, order: order)
    end

    it 'should create driver not found notification for few users' do
      expect_push_send(:driver_not_found, {
          alert: I18n.t('push_notification.driver_not_found', id: order.id)
      }, [user, user2])
      Push::Generator.call(users: [user, user2], notification: :driver_not_found, order: order)
    end

    it 'should create change status notification' do
      status = order.status.humanize.downcase
      expect_push_send(:change_status, {
          alert: I18n.t('push_notification.change_status', id: order.id, status: status)
      })
      Push::Generator.call(user: user, notification: :change_status, order: order)
    end

    it 'should create notification about new order for seller' do
      expect_push_send(:order_created, {
          alert: I18n.t('push_notification.order_created')
      })
      Push::Generator.call(user: user, notification: :order_created, order: order)
    end

    it 'should create notification about canceletion from seller' do
      expect_push_send(:canceled_by_seller, {
          alert: I18n.t('push_notification.canceled_by_seller', id: order.id)
      })
      Push::Generator.call(user: user, notification: :canceled_by_seller, order: order)
    end

    it 'should create notification about canceletion from driver' do
      expect_push_send(:canceled_by_driver, {
          alert: I18n.t('push_notification.canceled_by_driver', id: order.id)
      })
      Push::Generator.call(user: user, notification: :canceled_by_driver, order: order)
    end

    it 'should create notification about cooking time for seller' do
      expect_push_send(:cooking_time, {
          alert: I18n.t('push_notification.cooking_time', id: order.id)
      })
      Push::Generator.call(user: user, notification: :cooking_time, order: order)
    end

    it 'should return if can not find notification' do
      expect(Push::Send).not_to receive(:call)
      Push::Generator.call(user: user, notification: :test, order: order)
    end

    it 'should return if order empty' do
      expect(Push::Send).not_to receive(:call)
      Push::Generator.call(user: user, notification: :driver_not_found)
    end
  end
end
