require 'rails_helper'

RSpec.describe Api::V1::PaymentsController, type: :controller do
  json

  describe 'GET #new' do
    it 'render new page' do
      get :new, {:format => :html}
      expect(response.status).to eq(200)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    it 'should call Tokenization' do
      expect(Payments::Tokenization).to receive(:call).and_return(InteractorStub.new(options: {form: 'form'}))
      post :create
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #callback' do

    context 'with param tokenization_response' do
      it 'should render json with tokenization result' do
        expect(Payments::Response).to receive(:call).and_return(InteractorStub.new(options: {result: TOKENIZATION_RESPONSE}))
        get :callback, params: TOKENIZATION_RESPONSE
        expect(response.status).to eq(200)
        expect_json(TOKENIZATION_RESPONSE)
      end
    end

    context 'with param authorization_response' do
      it 'should render json with authorization result' do
        expect(Payments::Response).to receive(:call).and_return(InteractorStub.new(options: {result: AUTHORIZATION_RESPONSE}))
        get :callback, params: AUTHORIZATION_RESPONSE
        expect(response.status).to eq(200)
        expect_json(AUTHORIZATION_RESPONSE)
      end
    end


    # context 'with custom payfort response' do
    #   it 'should render json with authorization result' do
    #     get :callback, params: CUSTOM_PAYFORT_AUTHORIZATION_RESPONSE_SUCCESS
    #     expect(response.status).to eq(200)
    #     expect_json(AUTHORIZATION_RESPONSE)
    #   end
    # end

    context 'with unknown param' do
      it 'returns error' do
        allow(Payments::Response).to receive(:call).and_return(InteractorStub.new(failed: true, errors: 'Some error'))
        get :callback, params: AUTHORIZATION_RESPONSE
        expect(response).to have_http_status(422)
        expect(json['errors']).to include 'Some error'
      end
    end
  end
end
