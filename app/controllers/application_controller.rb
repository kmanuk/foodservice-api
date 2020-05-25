class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  AVAILABLE_LOCALES = %w(en ar)
  SIGN_UP_KEYS = %i(name phone token role)
  OAUTH_KEYS = %i(email name)
  ADDRESS_KEYS = { address_attributes: [:location, :latitude, :longitude] }

  BANK_KEYS = %i(bank_name iban)
  VEHICLE_KEYS = %i(car_type plate_number driver_license insurance_name insurance_number)

  ACCOUNT_UPDATE_KEYS = %i(business_name active_driver avatar video_snapshot video quickblox_user_id latitude longitude location active)

  before_action :configure_sanitized_params, if: :devise_controller?
  before_action :set_locale

  private

  def set_admin_timezone
    Time.zone = 'Asia/Riyadh'
  end

  def render_errors object, errors = [], status = :unprocessable_entity
    if object
      errors = object.errors.full_messages
    else
      errors = Array.wrap(errors)
    end
    render json: { status: status, errors: errors }, status: status
  end


  def set_locale
    locale = extract_locale_from_accept_language_header
    I18n.locale = AVAILABLE_LOCALES.detect { |l| l == locale } || I18n.default_locale
  end

  def extract_locale_from_accept_language_header
    request&.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
  end

  def set_admin_locale
    I18n.locale = I18n.default_locale
  end

  def configure_sanitized_params
    %i(sign_up account_update).each do |method|
      devise_parameter_sanitizer.permit(method, keys: SIGN_UP_KEYS + BANK_KEYS + VEHICLE_KEYS << ADDRESS_KEYS)
    end
    devise_parameter_sanitizer.permit(:account_update, keys: ACCOUNT_UPDATE_KEYS)
  end
end
