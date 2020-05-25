require 'rails_helper'

RSpec.describe Api::V1::ProductTypesController, type: :controller do
  render_views
  json

  let(:product_type_keys) do
    {
      id: :integer,
      name: :string
    }
  end

  let(:category_keys) do
    {
      id: :integer,
      name: :string,
      description: :string
    }
  end

  let(:sub_category_keys) do
    {
      id: :integer,
      name: :string,
      description: :string
    }
  end

  let!(:product_type) { create(:product_type, en: 'Farm', ar: 'mraF') }
  let!(:category) { create(:category, en: 'Fruits', ar: 'stiurF', product_type: product_type) }
  let!(:sub_category) { create(:sub_category, en: 'Orange', ar: 'egnarO', category: category) }

  describe 'GET #index' do
    ['en', 'ar'].each do |locale|
      context "for '#{locale}' locale" do
        before { request.env['HTTP_ACCEPT_LANGUAGE'] = locale }

        it 'returns all product types with all categories' do
          get :index
          expect(response).to have_http_status(200)

          expect_json_sizes('data.product_types', 1)
          expect_json_types('data.product_types.*', product_type_keys)
          expect_json('data.product_types.?', id: product_type.id, name: product_type[locale])

          expect_json_sizes('data.product_types.*.categories', 1)
          expect_json_types('data.product_types.*.categories.*', category_keys)
          expect_json('data.product_types.?.categories.?', id: category.id, name: category[locale])

          expect_json_types('data.product_types.*.categories.*', url: :string)

          expect_json_sizes('data.product_types.*.categories.*.sub_categories', 1)
          expect_json_types('data.product_types.*.categories.*.sub_categories.*', sub_category_keys)
          expect_json_types('data.product_types.*.categories.*.sub_categories.*', url: :string)
          expect_json('data.product_types.?.categories.?.sub_categories.?', id: sub_category.id, name: sub_category[locale])
        end
      end
    end

    context "for 'ru' locale" do
      before { request.env['HTTP_ACCEPT_LANGUAGE'] = 'ru' }

      it 'returns all product types with all categories with en translation' do
        get :index
        expect(response).to have_http_status(200)

        expect_json_sizes('data.product_types', 1)
        expect_json_types('data.product_types.*', product_type_keys)
        expect_json('data.product_types.?', id: product_type.id, name: product_type[I18n.default_locale])

        expect_json_sizes('data.product_types.*.categories', 1)
        expect_json_types('data.product_types.*.categories.*', category_keys)
        expect_json('data.product_types.?.categories.?', id: category.id, name: category[I18n.default_locale])

        expect_json_types('data.product_types.*.categories.*', url: :string)

        expect_json_sizes('data.product_types.*.categories.*.sub_categories', 1)
        expect_json_types('data.product_types.*.categories.*.sub_categories.*', sub_category_keys)
        expect_json_types('data.product_types.*.categories.*.sub_categories.*', url: :string)
        expect_json('data.product_types.?.categories.?.sub_categories.?', id: sub_category.id, name: sub_category[I18n.default_locale])
      end
    end
  end
end
