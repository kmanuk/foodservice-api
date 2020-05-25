module Docs::V1::Reviews
  extend Apipie::DSL::Concern

  def_param_group :id do
    param :id, Integer, 'Review ID', required: true
  end

  def_param_group :review do
    param :rate, [0,1,2,3,4,5], required: true
    param :message, String, required: false
    param :order_id, Integer, required: false
  end

  api! 'List of reviews'
  param :user_id, Integer, "Seller's ID", required: true
  def index; end

  api! 'Create review'
  param :user_id, Integer, "Seller's ID", required: true
  param_group :review

  def create;
  end

  api! 'Show review'
  param :user_id, Integer, "Seller's ID", required: true
  param_group :id
  def show; end

end
