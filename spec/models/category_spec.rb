require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:sub_categories).dependent(:destroy) }
    it { is_expected.to belong_to(:product_type) }
  end

  describe '#title' do
    let(:category) { create(:category, en: 'English', ar: 'Arabic') }

    context 'En localtion' do
      before { I18n.locale = :en }

      it 'returns English title' do
        expect(category.title).to eq('English')
      end
    end

    context 'Ar localtion' do
      before { I18n.locale = :ar }

      it 'returns English title' do
        expect(category.title).to eq('Arabic')
      end
    end


  end
end

# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  en              :string
#  description     :string
#  ar              :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  product_type_id :integer
#
# Indexes
#
#  index_categories_on_product_type_id  (product_type_id)
#
