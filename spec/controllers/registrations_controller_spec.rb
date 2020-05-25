require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  json

  let(:users_keys) do
    {id: :integer,
     email: :string,
     name: :string,
     quickblox_user_id: :integer,
     car_type: :string_or_null,
     plate_number: :string_or_null,
     driver_license: :string_or_null,
     insurance_name: :string_or_null,
     insurance_number: :string_or_null

    }
  end


  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'POST #create' do
    before { post :create, params: attributes_user }

    context 'without params' do
      let(:attributes_user) { attributes_for(:user) }

      it 'should create user' do
        expect(response).to have_http_status(:ok)
        expect(User.count).to eq 1
      end
    end

    context 'with address params' do
      let(:attributes_user) do
        attributes_for(:user).merge(address_attributes: {location: 'Kiev', latitude: 50.42039, longitude: 30.51263})
      end

      it 'should create user with address' do
        expect(response).to have_http_status(:ok)
        expect(User.count).to eq 1
        user = User.last
        expect(user.address).not_to be_nil
        expect(user.address.location).to eq 'Kiev'
        expect(user.address.latitude).to eq 50.42039
        expect(user.address.longitude).to eq 30.51263
      end
    end

    context 'with vehicle params' do
      let(:attributes_user) { attributes_for(:driver) }

      it 'should create user with vehicle params' do
        expect(response).to have_http_status(:ok)
        user = User.last
        expect(user.car_type).not_to be_nil
        expect(user.plate_number).not_to be_nil
        expect(user.driver_license).not_to be_nil
        expect(user.insurance_name).not_to be_nil
        expect(user.insurance_number).not_to be_nil
      end
    end

    context 'with bank params' do
      let(:attributes_user) { attributes_for(:seller) }

      it 'should create user with bank params' do
        expect(response).to have_http_status(:ok)
        user = User.last
        expect(user.iban).not_to be_nil
        expect(user.bank_name).not_to be_nil
      end
    end

    context 'with wrong params' do
      let(:attributes_user) do
        attributes_for(:user, email: 'sdfsdfsdf@i.')
      end

      it 'should render errors' do
        expect(response).to have_http_status(422)
        expect(json['status']).to eq 'unprocessable_entity'
        expect(json['errors']).to include 'Email is not an email'
      end
    end
  end

  describe 'PUT #update' do

    context 'User exist' do
      login

      it 'should update user' do
        put :update, params: {name: 'new_value',
                              token: '123456',
                              latitude: 123.12,
                              longitude: 12.123,
                              active_driver: false,
                              business_name: 'MyKitchen'}
        expect(response).to have_http_status(:ok)
        expect(@user.reload.name).to eq 'new_value'
        expect(@user.token).to eq '123456'
        expect(@user.latitude).to eq 123.12
        expect(@user.longitude).to eq 12.123
        expect(@user.business_name).to eq 'MyKitchen'
        expect(@user.active_driver).to be_falsey
      end

      it 'should reset user token' do
        put :update, params: {token: nil}
        expect(response).to have_http_status(:ok)
        expect(@user.reload.token).to eq ''
      end

      it 'should set user avatar' do
        put :update, params: attributes_for(:user, :with_avatar).slice(:avatar)

        @user.reload
        expect(response).to have_http_status(:ok)
        expect(@user.avatar_file_name).not_to be_nil
        expect(@user.avatar_content_type).not_to be_nil
        expect(@user.avatar_file_size).not_to be_nil
      end

      it 'should change user active' do
        put :update, params: attributes_for(:user, active: false)
        @user.reload
        expect(response).to have_http_status(:ok)
        expect(@user.active).to be_falsey
      end

      context 'with address' do
        it 'should create address' do
          put :update, params: {address_attributes: {location: 'Kiev', latitude: 50.42039, longitude: 30.51263}}
          @user.reload
          expect(response).to have_http_status(:ok)
          expect(@user.address).not_to be_nil
          expect(@user.address.location).to eq 'Kiev'
          expect(@user.address.latitude).to eq 50.42039
          expect(@user.address.longitude).to eq 30.51263
        end

        it 'should update address' do
          @user.update(address: create(:address))
          put :update, params: {address_attributes: {location: 'Kiev', latitude: 50.42039, longitude: 30.51263}}
          @user.reload
          expect(response).to have_http_status(:ok)
          expect(@user.address).not_to be_nil
          expect(@user.address.location).to eq 'Kiev'
          expect(@user.address.latitude).to eq 50.42039
          expect(@user.address.longitude).to eq 30.51263
        end
      end

      context 'with bank params' do
        it 'should create bank params' do
          put :update, params: {iban: '12345', bank_name: 'PrivatBank'}
          @user.reload
          expect(response).to have_http_status(:ok)
          expect(@user.iban).to eq '12345'
          expect(@user.bank_name).to eq 'PrivatBank'
        end

        it 'should update bank params' do
          @user.update(iban: '12345', bank_name: 'PrivatBank')
          put :update, params: {iban: '123457890', bank_name: 'OTP'}
          @user.reload
          expect(response).to have_http_status(:ok)
          expect(@user.iban).to eq '123457890'
          expect(@user.bank_name).to eq 'OTP'
        end
      end

      context 'with vehicle params' do
        it 'should create vehicle params' do
          put :update, params: {car_type: 'BMW',
                                plate_number: '123456',
                                driver_license: '9000',
                                insurance_name: 'Insurance Company',
                                insurance_number: '77777'}
          @user.reload
          expect(response).to have_http_status(:ok)
          expect(@user.car_type).to eq 'BMW'
          expect(@user.plate_number).to eq '123456'
          expect(@user.driver_license).to eq '9000'
          expect(@user.insurance_name).to eq 'Insurance Company'
          expect(@user.insurance_number).to eq '77777'
        end

        it 'should update vehicle params' do
          @user.update(car_type: 'BMW',
                       plate_number: '123456',
                       driver_license: '9000',
                       insurance_name: 'Insurance Company',
                       insurance_number: '77777')
          put :update, params: {car_type: 'Audi',
                                plate_number: '777',
                                driver_license: '123',
                                insurance_name: 'Insurance Company Two',
                                insurance_number: '66666'}
          @user.reload
          expect(response).to have_http_status(:ok)
          expect(@user.car_type).to eq 'Audi'
          expect(@user.plate_number).to eq '777'
          expect(@user.driver_license).to eq '123'
          expect(@user.insurance_name).to eq 'Insurance Company Two'
          expect(@user.insurance_number).to eq '66666'
        end
      end


      it 'should set user video with video_snapshot' do
        put :update, params: attributes_for(:user, :with_video).slice(:video, :video_snapshot)

        @user.reload
        expect(response).to have_http_status(:ok)
        expect(@user.video_file_name).not_to be_nil
        expect(@user.video_content_type).not_to be_nil
        expect(@user.video_file_size).not_to be_nil

        expect(@user.video_snapshot_file_name).not_to be_nil
        expect(@user.video_snapshot_content_type).not_to be_nil
        expect(@user.video_snapshot_file_size).not_to be_nil
      end

      context 'update role' do

        it 'get error with active paid orders' do
          create(:order, :with_payment_paid, buyer: @user, status: :ready)
          put :update, params: {role: :driver}
          expect(response).to have_http_status(422)
          expect(@user.reload).to be_buyer
          expect(json['errors']).to include "Role can't be switched with active orders"
        end

        it 'get error with active orders by cash' do
          create(:order, :by_cash, buyer: @user, status: :ready)
          put :update, params: {role: :driver}
          expect(response).to have_http_status(422)
          expect(@user.reload).to be_buyer
          expect(json['errors']).to include "Role can't be switched with active orders"
        end

        it 'can switch role with active unpaid orders' do
          create(:order, :with_payment, buyer: @user, status: :ready)
          put :update, params: {role: :driver}
          expect(response).to have_http_status(:ok)
          expect(@user.reload).to be_driver
        end
      end
    end

    context 'User does not exist' do

      it 'should render error 401' do
        put :update, params: {name: 'New Name'}
        expect(response).to have_http_status(:unprocessable_entity)
      end

    end

  end
end
