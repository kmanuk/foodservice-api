module Docs::V1::Addresses
  extend Apipie::DSL::Concern

  api! 'Get address'
  def index; end

  api! 'Create/Update address'
  param :address, Hash, required: true do
    param :location, String, required: true
    param :latitude, String, required: true
    param :longitude, String, required: true
  end
  def create; end
end
