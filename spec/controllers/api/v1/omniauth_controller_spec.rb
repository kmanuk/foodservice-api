require 'rails_helper'

RSpec.describe Api::V1::OmniauthController, type: :controller do
  json

  describe 'POST #index' do
    context 'for twitter provider' do
      context 'for wrong token' do
        it 'should render error' do
          stub_request(:get, 'https://api.twitter.com/1.1/account/verify_credentials.json?include_email=true').to_return(
            status: 401,
            body: { errors: 'Could not authenticate you.' }.to_json
          )

          post :create, params: { provider: 'twitter', access_token: '12345', access_token_secret: '12345' }

          expect(response).to have_http_status(401)
          expect(json['errors']).to include 'Could not authenticate you.'
        end
      end

      context 'for 404 from twitter' do
        it 'should render error' do
          stub_request(:get, 'https://api.twitter.com/1.1/account/verify_credentials.json?include_email=true').to_return(
            status: 404,
            body: { errors: 'Not found.' }.to_json
          )

          post :create, params: { provider: 'twitter', access_token: '12345', access_token_secret: '12345' }

          expect(response).to have_http_status(404)
          expect(json['errors']).to include 'Not found.'
        end
      end

      context 'for some twitter error' do
        it 'should render error' do
          stub_request(:get, 'https://api.twitter.com/1.1/account/verify_credentials.json?include_email=true').to_return(
            status: 403,
            body: { errors: 'Some internal error.' }.to_json
          )

          post :create, params: { provider: 'twitter', access_token: '12345', access_token_secret: '12345' }

          expect(response).to have_http_status(422)
          expect(json['errors']).to include 'Some internal error.'
        end
      end

      context 'with correct token' do
        context 'for new user' do
          it 'should create user' do
            post :create, params: {provider: 'twitter', token: 'push_token_123', access_token: '12345', access_token_secret: '12345', role: 'seller'}

            expect(response).to have_http_status(200)
            expect(User.count).to eq 1
            expect(User.first.provider).to eq 'twitter'
            expect(User.first.email).to eq 'test.last@gmail.com'
            expect(User.first.uid).to eq '3345259222'
            expect(User.first.name).to eq 'Alexander'
            expect(User.first.role).to eq 'seller'
            expect(User.first.token).to eq('push_token_123')

            expect_json_keys('data', User.first.as_json.symbolize_keys.keys)
            expect_json('data', id: User.first.id)
          end

          it 'should return auth headers' do
            post :create, params: { provider: 'twitter', access_token: '12345', access_token_secret: '12345' }

            user = User.first

            expect(response.headers['access-token']).not_to be_nil
            expect(response.headers['token-type']).to eq 'Bearer'
            expect(response.headers['client']).not_to be_nil
            expect(response.headers['expiry']).not_to be_nil

            user.valid_token?(response.headers['access-token'], response.headers['client'])
          end
        end

        context 'for existing user' do
          let!(:user) { create(:user, token: 'updated_push_token123', provider: 'twitter', uid: '3345259222', role: 'buyer') }

          it 'should find user' do
            post :create, params: { provider: 'twitter', access_token: '12345', access_token_secret: '12345', role: 'seller' }

            expect(response).to have_http_status(200)
            expect(User.count).to eq 1
            expect(user.reload.role).to eq 'seller'
            expect(user.reload.token).to eq 'updated_push_token123'
            expect_json_keys('data', user.as_json.symbolize_keys.keys)
            expect_json('data', id: user.id)
          end

          it 'should return auth headers' do
            post :create, params: { provider: 'twitter', access_token: '12345', access_token_secret: '12345' }

            expect(response.headers['access-token']).not_to be_nil
            expect(response.headers['token-type']).to eq 'Bearer'
            expect(response.headers['client']).not_to be_nil
            expect(response.headers['expiry']).not_to be_nil

            user.reload.valid_token?(response.headers['access-token'], response.headers['client'])
          end
        end
      end
    end

    context 'for other provider' do
      it 'should render error' do
        post :create, params: { provider: 'google' }
        expect(response).to have_http_status(400)
      end
    end
  end
end
