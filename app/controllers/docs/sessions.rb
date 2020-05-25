module Docs::Sessions
  extend Apipie::DSL::Concern

  api! 'Sign In'
  param :email, String, required: true
  param :password, String, required: true
  param :role, String
  param :token, String
  def create
    super
  end

  api! 'Sign Out'
  def destroy
    super
  end
end
