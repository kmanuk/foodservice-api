require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  render_views
  json

  let(:users_keys) do
    {id: :integer,
     email: :string,
     name: :string,
     quickblox_user_id: :integer,
     push_count_messages: :integer,
     push_count_orders: :integer,
     avatar_url: :string,
     avatar_thumb: :string,
     role: :string,
     phone: :string
    }
  end

  let(:sellers_keys) do
    users_keys.merge({recommended_seller: :boolean,
                      av_rate: :float_or_null,
                      reviews: :integer,
                      business_name: :string_or_null,
                      video_snapshot_url: :string_or_null,
                      video_url: :string_or_null})
  end

  let(:drivers_keys) do
    users_keys.merge({active_driver: :boolean})
  end


  context 'when authorized user' do
    login

    describe 'GET #show' do

      it 'returns info about seller' do
        seller = create(:seller)
        get :show, id: seller.id
        expect(response).to have_http_status(:success)
        expect_json_types('data', sellers_keys)
      end

      it 'returns info about driver' do
        driver = create(:driver)
        get :show, id: driver.id
        expect(response).to have_http_status(:success)
        expect_json_types('data', drivers_keys)
      end

      it 'returns info about buyer' do
        buyer = create(:buyer)
        get :show, id: buyer.id
        expect(response).to have_http_status(:success)
      end


      it 'returns not found if user does not exist' do
        get :show, params: {id: 999}
        expect(response).to have_http_status(404)
      end

    end

  end
end
