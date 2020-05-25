require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  json

  describe 'constants' do
    it 'should set AVAILABLE_LOCALES' do
      expect(ApiController::AVAILABLE_LOCALES).to eq %w(en ar)
    end

    it 'should set registration constants' do
      expect(ApiController::SIGN_UP_KEYS).to eq %i(name phone token role)
      expect(ApiController::ADDRESS_KEYS).to eq({ address_attributes: [:location, :latitude, :longitude] })
      expect(ApiController::ACCOUNT_UPDATE_KEYS).to eq %i(business_name active_driver avatar video_snapshot video quickblox_user_id latitude longitude location active)

      expect(ApiController::BANK_KEYS).to eq %i(bank_name iban)
      expect(ApiController::VEHICLE_KEYS).to eq %i(car_type plate_number driver_license insurance_name insurance_number)

    end
  end

  describe '#set_locale' do
    controller do
      def index
        render nothing: true
      end
    end

    it 'should use default locale' do
      get :index
      expect(I18n.locale).to eq :en
    end

    it 'should parse locale from headers' do
      request.headers.merge! HTTP_ACCEPT_LANGUAGE: 'ar'
      get :index
      expect(I18n.locale).to eq :ar
    end

    it 'should set default for unavailable locale' do
      request.headers.merge! HTTP_ACCEPT_LANGUAGE: 'pd'
      get :index
      expect(I18n.locale).to eq :en
    end
  end
end
