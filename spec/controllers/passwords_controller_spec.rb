require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  json

  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'POST #create' do
    context 'without errors' do
      let(:user) { create(:user) }
      before { post :create, params: {email: user.email} }

      it 'should return status 200' do
        expect(response).to have_http_status(200)
        expect(json['message']).to eq "An email has been sent to '#{user.email}' containing instructions for resetting your password."
      end

      it 'should send email with temp password' do
        expect(ActionMailer::Base.deliveries.count).to eq 1
      end
    end

    context 'with errors' do
      it 'should render error if can not find email' do
        post :create
        expect(response).to have_http_status(401)
        expect(json['errors']).to include 'You must provide an email address.'
      end

      it 'should render error if can not find user' do
        post :create, params: {email: 'some@email.com'}
        expect(response).to have_http_status(404)
        expect(json['errors']).to include "Unable to find user with email some@email.com."
      end
    end
  end


  describe 'GET #edit' do
    let(:user) { create(:user) }
    it 'send new password' do
      expect_any_instance_of(User).to receive(:send_password_change_notification)

      user.update(reset_password_token: Devise.token_generator.digest(self, :reset_password_token, '123'))
      get :edit, {reset_password_token: '123'}
      expect(response.body).to eq I18n.t('devise.passwords.updated_not_active')
    end


    it 'render message that link has been expired' do
      user.update(reset_password_token: Devise.token_generator.digest(self, :reset_password_token, '1234'))
      get :edit, {reset_password_token: '123'}
      expect(response.body).to eq I18n.t('devise.passwords.expire_link')
    end
  end
end
