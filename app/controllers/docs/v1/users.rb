module Docs::V1::Users
  extend Apipie::DSL::Concern

  def_param_group :id do
    param :id, Integer, 'User ID', required: true
  end

  api! 'Show user'
  param_group :id
  def show; end

end
