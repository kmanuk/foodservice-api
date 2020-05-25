require 'rails_helper'

describe Admin::SellersController, type: :controller do

  context 'GET #index' do
    login_admin

    after do
      Time.zone = 'UTC'
    end

    it 'list of sellers' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'has time zone Asia/Riyadh' do
      get :index
      expect(Time.zone.name).to eq 'Asia/Riyadh'
    end


  end

end


