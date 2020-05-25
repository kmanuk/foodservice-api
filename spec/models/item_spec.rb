require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'constants' do
    it { expect(Item::SERVICE_FEE).to eq 0.1 }
  end

  describe 'macros' do
    it { is_expected.to enumerize(:type) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:sub_category) }
    it { is_expected.to have_one(:image) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:type).in_array(Item.type.values) }
    it { is_expected.to validate_presence_of(:name) }

    context 'if preorder' do
      before { allow(subject).to receive(:preorder?).and_return(true) }
      it { is_expected.to validate_numericality_of(:time_to_cook).is_greater_than(0) }
    end

    context 'if live/free' do
      before { allow(subject).to receive(:preorder?).and_return(false) }
      it { is_expected.not_to validate_numericality_of(:time_to_cook).is_greater_than(0) }
    end

  end

  context 'callbacks' do
    describe '#calculate_total_price' do
      let(:item) { create(:item, price: 10.0) }

      it 'should calculate price with fee' do
        expect(item.total_price).to eq (10.0 + 10.0 * Item::SERVICE_FEE).round(2)
      end
    end
  end

  context 'filters' do
    describe '.valid_filters' do
      subject { Item.valid_filters }

      it { is_expected.to eq(%w(search category sub_category type sellers_rate location product_type seller)) }
    end

    describe '.with_location' do
      it 'should find items with users by location' do

        seller_in_germany = create(:seller, address: create(:address_germany))
        create_list(:item, 2, user: seller_in_germany)

        address = create(:address, location: 'Kiev, Khreshchatyk, Ukraine')
        user = create(:user, address: address)
        item = create(:item, user: user)

        location = {
            bottom_left_latitude: 50.0,
            bottom_left_longitude: 30.0,
            top_right_latitude: 51.0,
            top_right_longitude: 31.0
        }

        expect(Item.with_location(location).size).to eq 1
        expect(Item.with_location(location).first).to eq item
      end
    end
  end
end

# == Schema Information
#
# Table name: items
#
#  id              :integer          not null, primary key
#  sub_category_id :integer
#  user_id         :integer
#  information     :text
#  price           :float            default("0.0")
#  amount          :integer          default("1")
#  time_to_cook    :float            default("0.0")
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  name            :string
#  product_type_id :integer
#  category_id     :integer
#  total_price     :float
#
# Indexes
#
#  index_items_on_category_id      (category_id)
#  index_items_on_product_type_id  (product_type_id)
#  index_items_on_sub_category_id  (sub_category_id)
#  index_items_on_type             (type)
#  index_items_on_user_id          (user_id)
#
