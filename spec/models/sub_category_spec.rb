require 'rails_helper'

RSpec.describe SubCategory, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:items) }
    it { is_expected.to belong_to(:category) }
  end

  describe '#title' do
    let(:sub_category) { create(:sub_category, en: 'English', ar: 'Arabic') }

    context 'En location' do
      before { I18n.locale = :en }

      it 'returns English title' do
        expect(sub_category.title).to eq('English')
      end
    end

    context 'Ar location' do
      before { I18n.locale = :ar }

      it 'returns English title' do
        expect(sub_category.title).to eq('Arabic')
      end
    end


  end
end

# == Schema Information
#
# Table name: sub_categories
#
#  id          :integer          not null, primary key
#  en          :string
#  description :string
#  ar          :string
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_sub_categories_on_category_id  (category_id)
#
