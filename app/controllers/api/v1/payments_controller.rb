class Api::V1::PaymentsController < ApplicationController
  resource_description do
    formats [:json]
    api_version 'v1'
  end
  include Docs::V1::Payments

  def new

  end

  def create
    form = Payments::Tokenization.call.form
    render json: {form: form}
  end


  def callback
    payment_result = Payments::Response.call(params: callback_params)
    if payment_result.success?
      render json: payment_result.result
    else
      render_errors nil, payment_result.errors
    end
  end


  def callback_params
    params.permit(:r, :response_code, :order,
                  :signature, :remember_me,
                  :card_number,
                  :authorization_code,
                  :card_holder_name,
                  :merchant_identifier,
                  :expiry_date,
                  :access_code,
                  :language,
                  :service_command,
                  :response_message,
                  :merchant_reference,
                  :token_name, :return_url, :card_bin, :status,
                  :amount, :payment_option, :customer_ip, :eci,
                  :fort_id, :command, :customer_email, :currency, :customer_name
    )
  end

end
