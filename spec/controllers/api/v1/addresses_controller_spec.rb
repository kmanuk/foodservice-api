require 'rails_helper'

RSpec.describe Api::V1::AddressesController, type: :controller do
  render_views
  json

  context 'when unauthorized user' do
    it_behaves_like 'render 401', :get, :index
    it_behaves_like 'render 401', :post, :create
  end

  context 'when authorized user' do
    login

    let(:address_keys) do
      {
          id: :integer,
          location: :string,
          latitude: :float,
          longitude: :float
      }
    end

    describe 'GET #index' do
      let(:address) { create(:address) }

      context 'when user has address' do
        it "should return user's address" do
          @user.update(address: address)
          get :index
          expect(response).to have_http_status(200)
          expect_json_types('data.address', address_keys)
          expect_json('data.address', location: address.location, longitude: address.longitude, latitude: address.latitude)
        end
      end

      context 'when user without address' do
        it 'returns 404' do
          get :index
          expect(response).to have_http_status(404)
        end

      end


    end

    describe 'POST #create' do
      let(:address) { create(:address) }

      context 'with correct params' do
        it 'should create address' do
          post :create, params: {address: {location: '22 Khreshchatyk ,Kiev, Ukraine',
                                           latitude: 50.447174,
                                           longitude: 30.521893}
          }
          expect(response).to have_http_status(200)
          expect_json_types('data.address', address_keys)
          expect_json('data.address', location: '22 Khreshchatyk ,Kiev, Ukraine', latitude: 50.447174, longitude: 30.521893)
        end

        it 'should update address' do
          @user.update(address: address)
          post :create, params: {address: {location: '19 Khreshchatyk ,Kiev, Ukraine',
                                           latitude: 50.447174,
                                           longitude: 30.521893}
          }
          expect(response).to have_http_status(200)
          expect_json_types('data.address', address_keys)
          expect_json('data.address', location: '19 Khreshchatyk ,Kiev, Ukraine', latitude: 50.447174, longitude: 30.521893)
        end

      end

      context 'with wrong params' do
        it 'should return error' do
          @user.update(address: address)
          post :create, params: {address: {longitude: ''}}
          expect(response).to have_http_status(422)
          expect(json['errors']).to include "Longitude can't be blank"
        end
      end
    end
  end
end
