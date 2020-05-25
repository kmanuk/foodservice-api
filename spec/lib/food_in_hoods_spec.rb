require 'rails_helper'

RSpec.describe FoodInHoods do
  describe 'ActiveRecord::Relation #paginate' do
    let!(:users) { create_list(:admin_user, 50) }

    def paginate page: nil, per_page: nil
      AdminUser.all.paginate(page, per_page).to_a
    end

    it 'without params split results by page' do
      results = paginate
      expect(results.size).to eq(25)
    end

    it 'change objects per page value' do
      results = paginate
      new_results = paginate(page: 2)
      expect(new_results).not_to eq(results)
    end

    it 'change objects per page value' do
      results = paginate(per_page: 50)
      expect(results.size).to eq(50)
    end
  end

  describe 'String #initial' do
    let(:string) { String.new('Test') }
    it 'returns first letter of the string' do
      expect(string.initial).to eq 'T'
    end
  end

  describe 'Array  #blank_inside?' do
    let(:array_1) { Array.new([1, 2, 3, 4]) }
    let(:array_2) { Array.new([]) }

    it 'returns false if array is not blank' do
      expect(array_1.blank_inside?).to be_falsey
    end

    it 'returns true if array is blank' do
      expect(array_2.blank_inside?).to be_truthy
    end

  end


  describe 'Hash #camelize_keys!' do
    let(:hash) do
      {
          camel_key: [
              'string',
              11,
              {nested_key: {one_more_nested_key: 'string'}}
          ]
      }
    end

    it 'shoud make all keys camelize' do
      result = {
          camelKey: [
              'string',
              11,
              {nestedKey: {oneMoreNestedKey: 'string'}}
          ]
      }
      expect(hash.camelize_keys!).to eq result
    end
  end

  describe 'Convert' do
    describe '.dollars_to_cents' do
      it 'should convert amount' do
        result = Convert.dollars_to_cents(18.9)
        expect(result).to be_a Integer
        expect(result).to eq 1890
      end

      it 'should convert string amount' do
        result = Convert.dollars_to_cents('18.9')
        expect(result).to be_a Integer
        expect(result).to eq 1890
      end
    end

    describe '.cents_to_dollars' do
      it 'should convert amount' do
        result = Convert.cents_to_dollars(1890)
        expect(result).to be_a Float
        expect(result).to eq 18.9
      end
    end
  end

  describe 'Enumerable #each_with_previous' do
    it 'should iterate with current and previous elements' do
      array = []
      [10, 30, 100].each_with_previous do |prev, curr|
        array << [prev, curr]
      end
      expect(array).to eq [[nil, 10], [10, 30], [30, 100]]
    end
  end
end
