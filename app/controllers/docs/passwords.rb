module Docs::Passwords
  extend Apipie::DSL::Concern

  api! 'Reset password request'
  param :email, String, required: true
  def create
    super
  end
end
