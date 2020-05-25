module Docs::V1::Omniauth
  extend Apipie::DSL::Concern

  api! 'Log In with oauth account'
  param :provider, String, 'Auth provider', required: true

  param :access_token, String, required: true
  param :access_token_secret, String, required: true

  param :name, String
  param :email, String
  param :phone, String
  param :token, String, 'Apple push notification token'
  param :role, User::ROLES_OPTIONS
  def create; end
end
