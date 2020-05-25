require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'constants' do
    it { expect(Order::DISTANCE_RANGE).to eq [10, 30, 100] }
    it { expect(Order::REGULAR_DELIVERY).to eq 3 }
    it { expect(Order::CERTIFIED_DELIVERY).to eq 5 }
    it { expect(Order::KM_PRICE).to eq 0.6 }
    it { expect(Order::SERVICE_FEE).to eq 2 }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:seller) }
    it { is_expected.to belong_to(:buyer) }
    it { is_expected.to belong_to(:address) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to allow_values('free', 'live', 'preorder', 1, 2, 0).for(:type) }
    it { is_expected.to allow_values('card', 'cash', 0, 1).for(:payment_type) }
    it { is_expected.to allow_values('self_delivery', 'regular_driver', 'certified_driver', 0, 1, 2).for(:delivery_type) }
    it { is_expected.to allow_values('pending',
                                     'canceled',
                                     'cooking',
                                     'ready',
                                     'looking_for_driver',
                                     'on_the_way',
                                     'delivered',
                                     0, 1, 2, 3, 4, 5, 6).for(:status) }
    it { is_expected.to respond_to(:id) }
    it { is_expected.to respond_to(:buyer_id) }
    it { is_expected.to respond_to(:seller_id) }
    it { is_expected.to respond_to(:driver_id) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:confirmed_at) }
    it { is_expected.to respond_to(:pickedup_at) }
    it { is_expected.to respond_to(:delivered_at) }
    it { is_expected.to respond_to(:delivery_type) }
    it { is_expected.to respond_to(:type) }
    it { is_expected.to respond_to(:payment_type) }
    it { is_expected.to respond_to(:payment_id) }
    it { is_expected.to respond_to(:price) }
    it { is_expected.to respond_to(:delivery_price) }
    it { is_expected.to respond_to(:fee_price) }
    it { is_expected.to respond_to(:address) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:delivery_type) }
    it { is_expected.to validate_presence_of(:line_items) }
  end

  context 'scopes' do

    before do
      create(:fast_created_order, status: :canceled)
      create(:fast_created_order, status: :delivered)
      create(:fast_created_order, status: :cooking)
      create(:fast_created_order, status: :looking_for_driver)
    end

    describe '.active' do
      it 'should return only active orders' do
        expect(Order.active.size).to eq 2
        expect(Order.active.first.status).to eq 'cooking'
        expect(Order.active.last.status).to eq 'looking_for_driver'
      end
    end

    describe '.looking_driver' do
      it 'should return only orders with status looking_for_drivers' do
         expect(Order.looking_driver.size).to eq 1
        expect(Order.looking_driver.last.status).to eq 'looking_for_driver'
      end
    end
  end

  describe '#members' do
    context 'without driver' do
      it 'should return array of users without driver' do
        order = create(:order, driver: nil)
        expect(order.members).to eq [order.seller, order.buyer]
      end
    end

    context 'with driver' do
      it 'should return array of users with driver' do
        order = create(:order)
        expect(order.members).to eq [order.seller, order.buyer, order.driver]
      end
    end

    context 'with exclude' do
      it 'should exclude user from list' do
        order = create(:order, driver: nil)
        expect(order.members(exclude: order.buyer.id)).to eq [order.seller]
      end
    end
  end

  describe '#linked_with' do
    let(:order) { create(:order) }

    it 'should check if user linked with order' do
      expect(order.linked_with?(0)).to be false
      expect(order.linked_with?(order.seller_id)).to be true
      expect(order.linked_with?(order.buyer_id)).to be true
      expect(order.linked_with?(order.driver_id)).to be true
    end
  end

  describe '#cancel!' do
    let(:order) { create(:fast_created_order, status: :cooking) }

    it 'should cancel order' do
      order.cancel!
      expect(order.status).to eq 'canceled'
    end
  end

  describe '#find_driver!' do
    let(:order) { create(:fast_created_order) }

    it 'should return if self delivery' do
      order.delivery_type = :self_delivery
      expect(DriverFinderWorker).not_to receive(:perform_in)
      order.find_driver! with_canceletion: false
    end

    it 'should call DriverFinderWorker' do
      expect(DriverFinderWorker).to receive(:perform_in).exactly(3).times
      order.find_driver! with_canceletion: false
    end

    it 'should call DriverFinderWorker with correct params' do
      delay = 0
      Order::DISTANCE_RANGE.each_with_previous do |previous, current|
        expect(DriverFinderWorker).to receive(:perform_in).with(delay.minutes, order.id, certified: false, distance: current, except_distance: previous).at_least(:once)
        delay += 2
      end
      order.find_driver! with_canceletion: false
    end

    context 'with canceletion' do
      it 'should call OrderCanceletionWorker' do
        expect(OrderCanceletionWorker).to receive(:perform_in).with(6.minutes, order.id, :system)
        order.find_driver!
      end
    end

    context 'without canceletion' do
      it 'should not call OrderCanceletionWorker' do
        expect(OrderCanceletionWorker).not_to receive(:perform_in)
        order.find_driver! with_canceletion: false
      end
    end
  end


  shared_examples 'order has statuses' do |statuses|
    it 'returns arrays with possible statuses' do
      expect(order.possible_statuses).to eq(statuses)
      expect(order.possible_statuses_with_cancel).to eq(statuses + ['canceled'])
    end
  end

  shared_examples 'next status after' do |current_status, next_status|
    it 'returns next status' do
      order.update(status: current_status)
      expect(order.next_status).to eq(next_status)
    end
  end

  shared_examples 'order with status can change' do |status, role|
    it 'returns role' do
      order.update(status: status)
      expect(order.who_can_change).to eq(role)
    end
  end

  shared_examples 'order can cancel' do |status, role|
    it "#{role}" do
      order.update(status: status)
      expect(order.who_can_cancel).to eq(role)
    end
  end

  describe '#possible_statuses' do
    context 'preorder' do
      context 'self delivery' do
        let(:order) { create(:order, :preorder, :self_delivery) }
        it_behaves_like 'order has statuses', %w(pending cooking ready delivered)
      end

      context 'driver delivery' do
        let(:order) { create(:order, :preorder) }
        it_behaves_like 'order has statuses', %w(pending looking_for_driver cooking ready picking_up on_the_way delivered)
      end
    end

    context 'live/free' do
      context 'self delivery' do
        let(:order) { create(:order, :self_delivery) }
        it_behaves_like 'order has statuses', %w(pending ready delivered)
      end

      context 'driver delivery' do
        let(:order) { create(:order) }
        it_behaves_like 'order has statuses', %w(pending looking_for_driver ready picking_up on_the_way delivered)
      end
    end
  end


  describe '#review_added?' do
    let(:order) { create(:order) }

    context 'without reviews for seller' do
      it 'should return false' do
        create(:review, order: order, status: 'seller')
        expect(order.review_added?).to be true
      end
    end

    context 'with reviews for seller' do
      it 'should return true' do
        create(:review, order: order, status: 'driver')
        expect(order.review_added?).to be false
      end
    end
  end

  describe '#next_status' do
    context 'preorder' do
      context 'self delivery' do
        let(:order) { create(:fast_created_order, :preorder, :self_delivery) }

        it_behaves_like 'next status after', 'pending', 'cooking'
        it_behaves_like 'next status after', 'cooking', 'ready'
        it_behaves_like 'next status after', 'ready', 'delivered'

        it_behaves_like 'next status after', 'delivered', nil
        it_behaves_like 'next status after', 'canceled', nil
      end

      context 'driver delivery' do
        let(:order) { create(:fast_created_order, :preorder) }

        it_behaves_like 'next status after', 'pending', 'looking_for_driver'
        it_behaves_like 'next status after', 'looking_for_driver', 'cooking'
        it_behaves_like 'next status after', 'cooking', 'ready'
        it_behaves_like 'next status after', 'ready', 'picking_up'
        it_behaves_like 'next status after', 'picking_up', 'on_the_way'
        it_behaves_like 'next status after', 'on_the_way', 'delivered'

      end


    end

    context 'live/free' do
      context 'self delivery' do
        let(:order) { create(:fast_created_order, :free_order, :self_delivery) }

        it_behaves_like 'next status after', 'pending', 'ready'
        it_behaves_like 'next status after', 'ready', 'delivered'
      end

      context 'driver delivery' do
        let(:order) { create(:fast_created_order, :free_order) }

        it_behaves_like 'next status after', 'pending', 'looking_for_driver'
        it_behaves_like 'next status after', 'looking_for_driver', 'ready'
        it_behaves_like 'next status after', 'ready', 'picking_up'
        it_behaves_like 'next status after', 'picking_up', 'on_the_way'
        it_behaves_like 'next status after', 'on_the_way', 'delivered'

      end
    end

    describe '#review_added?' do
      let(:order) { create(:fast_created_order) }

      context 'without reviews for seller' do
        it 'should return false' do
          create(:review, order: order, status: 'seller')
          expect(order.review_added?).to be true
        end
      end

      context 'with reviews for seller' do
        it 'should return true' do
          create(:review, order: order, status: 'driver')
          expect(order.review_added?).to be false
        end
      end
    end
  end

  describe '#who_can_change' do

    let(:order) { create(:fast_created_order, :preorder) }

    it_behaves_like 'order with status can change', 'pending', 'seller'
    it_behaves_like 'order with status can change', 'cooking', 'seller'
    it_behaves_like 'order with status can change', 'looking_for_driver', 'driver'
    it_behaves_like 'order with status can change', 'picking_up', 'driver'
    it_behaves_like 'order with status can change', 'on_the_way', 'driver'
    it_behaves_like 'order with status can change', 'ready', 'driver'

    context 'self delivery' do
      let(:order) { create(:fast_created_order, :preorder, :self_delivery) }
      it_behaves_like 'order with status can change', 'ready', 'buyer'
    end


  end

  describe '#who_can_cancel' do

    let(:order) { create(:fast_created_order, :preorder) }

    it_behaves_like 'order can cancel', 'pending', %w(seller)
    it_behaves_like 'order can cancel', 'looking_for_driver', %w(seller)
    it_behaves_like 'order can cancel', 'cooking', %w(seller driver)
    it_behaves_like 'order can cancel', 'ready', %w(seller driver)

  end

end

# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  buyer_id         :integer
#  seller_id        :integer
#  driver_id        :integer
#  status           :integer          default("0"), not null
#  confirmed_at     :datetime
#  pickedup_at      :datetime
#  delivered_at     :datetime
#  delivery_type    :integer
#  payment_type     :integer
#  payment_id       :integer
#  price            :float
#  delivery_price   :float
#  fee_price        :float
#  address_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  type             :integer
#  distance         :integer          default("0")
#  duration         :integer          default("0")
#  polyline         :text             default("")
#  delivery_steps   :jsonb            default("{}"), not null
#  cooking_time     :integer
#  estimation_ready :datetime
#  service_fee      :float
#  paid             :boolean          default("false")
#  total_price      :float
#  global_price     :float
#
# Indexes
#
#  index_orders_on_address_id  (address_id)
#  index_orders_on_buyer_id    (buyer_id)
#  index_orders_on_driver_id   (driver_id)
#  index_orders_on_seller_id   (seller_id)
#
