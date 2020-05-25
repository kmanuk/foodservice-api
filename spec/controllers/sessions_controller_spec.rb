require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  json

  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'POST #create' do
    let!(:user) { create(:user, email: 'some@email.com', password: '12345678') }

    context 'without role' do
      it 'should login user' do
        post :create, params: {email: 'some@email.com', password: '12345678'}

        expect(response).to have_http_status(200)
        expect(json['data']['id']).to eq user.id
        expect(json['data']['email']).to eq user.email
      end
    end

    context 'with role' do
      let!(:seller) { create(:seller, email: 'seller@email.com', password: '12345678') }

      it 'should login seller' do

        post :create, params: {email: 'seller@email.com', password: '12345678'}
        expect(response).to have_http_status(200)
        expect(json['data']['id']).to eq seller.id
        expect(json['data']['email']).to eq seller.email
        expect(json['data']['role']).to eq seller.role
        expect(json['data']['name']).to eq seller.name
        expect(json['data']['uid']).to eq seller.uid
        expect(json['data']['locale']).to eq seller.locale
        expect(json['data']['phone']).to eq seller.phone
        expect(json['data']['token']).to eq seller.token
        expect(json['data']['quickblox_user_id']).to eq seller.quickblox_user_id
        expect(json['data']['address']['location']).to eq seller.address.location
        expect(json['data']['address']['latitude']).to eq seller.address.latitude
        expect(json['data']['address']['longitude']).to eq seller.address.longitude
      end


      it 'should change user role' do
        expect(user.role).to eq 'buyer'

        post :create, params: {email: 'some@email.com', password: '12345678', role: 'seller'}
        expect(response).to have_http_status(200)
        expect(json['data']['id']).to eq user.id
        expect(json['data']['email']).to eq user.email
        expect(json['data']['role']).to eq 'seller'
      end
    end

    context 'with token' do
      let!(:user) { create(:user, email: 'user@email.com', password: '12345678', token: '') }

      it 'should change user token' do
        expect(user.token).to eq ''

        post :create, params: {email: 'user@email.com', password: '12345678', token: '1234567890'}
        expect(response).to have_http_status(200)
        expect(json['data']['id']).to eq user.id
        expect(json['data']['email']).to eq user.email
        expect(json['data']['token']).to eq '1234567890'
      end
    end

    it 'should set locale' do
      request.headers.merge! HTTP_ACCEPT_LANGUAGE: 'ar'
      post :create, params: {email: 'some@email.com', password: '12345678'}

      expect(response).to have_http_status(200)
      expect(json['data']['locale']).to eq 'ar'
    end

    it 'retruns unprocessable_entity if cannot save user' do
      allow_any_instance_of(User).to receive(:save).and_return(false)
      post :create, params: {email: 'some@email.com', password: '12345678'}
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'retruns unauthorized if password blank' do
      post :create, params: {email: 'some@email.com', password: ''}
      expect(response).to have_http_status(:unauthorized)
    end


    it 'retruns unauthorized if user needs additional authentication' do
      allow_any_instance_of(User).to receive(:active_for_authentication?).and_return(false)
      post :create, params: {email: 'some@email.com', password: '12345678'}
      expect(response).to have_http_status(:unauthorized)
    end

    it 'retruns unauthorized if bad credentials' do
      post :create, params: {password: '12345678'}
      expect(response).to have_http_status(:unauthorized)
    end

  end

  describe 'DELETE #destroy' do
    login

    context 'with active orders' do
      it 'should render 422' do
        create(:order, :with_payment_paid, status: :ready, buyer: @user)
        delete :destroy
        expect(response).to have_http_status(422)
        expect(json['errors']).to include "You can't logout with active orders"
        expect(subject.current_user.tokens).not_to be_empty
      end

      it 'should allow logout with unpaid active orders' do
        create(:order, :with_payment, status: :ready, buyer: @user)
        expect(subject.current_user.tokens).not_to be_empty
        delete :destroy
        expect(subject.current_user.tokens).to be_empty
      end

    end

    context 'without active orders' do

      it 'should logout' do
        expect(subject.current_user.tokens).not_to be_empty
        delete :destroy
        expect(subject.current_user.tokens).to be_empty
      end

      it 'should destroy push token' do
        subject.current_user.update(token: '12345')
        expect(subject.current_user.token).not_to be_nil
        delete :destroy
        expect(subject.current_user.token).to be_nil
      end

      it 'should deactivate user' do
        @user.update(active: true, active_driver: true)
        delete :destroy
        @user.reload
        expect(@user.active).to be false
        expect(@user.active_driver).to be false
      end
    end


  end
end
