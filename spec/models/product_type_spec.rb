require 'rails_helper'

RSpec.describe ProductType, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:categories).dependent(:destroy) }
  end

  describe '#title' do
    let(:product_type) { create(:product_type, en: 'English', ar: 'Arabic') }

    context 'En localtion' do
      before { I18n.locale = :en }

      it 'returns English title' do
        expect(product_type.title).to eq('English')
      end
    end

    context 'Ar localtion' do
      before { I18n.locale = :ar }

      it 'returns English title' do
        expect(product_type.title).to eq('Arabic')
      end
    end


  end
end

# == Schema Information
#
# Table name: product_types
#
#  id         :integer          not null, primary key
#  en         :string
#  ar         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
