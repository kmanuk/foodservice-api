module Docs::Registrations
  extend Apipie::DSL::Concern

  def_param_group :base do
    param :name, String
    param :email, String
    param :phone, String
    param :token, String, 'Apple push notification token'
    param :role, User::ROLES_OPTIONS
    param :password, String
    param :password_confirmation, String
    param :iban, String
    param :bank_name, String
    param :car_type, String
    param :plate_number, String
    param :driver_license, String
    param :insurance_name, String
    param :insurance_number, String
    param :address_attributes, Hash do
      param :location, String
      param :latitude, String
      param :longitude, String
    end
  end

  api! 'Sign up'
  param_group :base
  def create
    super
  end

  api! 'Update information for user'
  param_group :base
  param :avatar, File
  param :video, File
  param :video_snapshot, File
  param :quickblox_user_id, Integer
  param :latitude, Float
  param :longitude, Float
  param :active, [true, false], 'Mark seller an active (Kitchen OFF/ON)'
  param :active_driver, [true, false], 'Mark driver as inactive'
  def update
    super
  end
end
