class Payments::Tokenization < Payments::Base

  include Interactor

  def call
    params = DEFAULT_OPTIONS.merge(
        service_command: 'TOKENIZATION',
        merchant_reference: generate_merchant_reference,
        language: I18n.locale.to_s,
        return_url: Rails.configuration.front_end_url + "/api/v1/payments/callback?r=tokenization_response"
    )
    params[:signature] = generate_signature(params)
    params[:remember_me] = 'NO'
    @form = get_payment_form(checkout_url, params)
  end

  after do
    context.form = @form
  end

  private

  def get_payment_form(gateway_url, post_data)
    form = "<form style=\"display:none\" name=\"payfort_payment_form\" id=\"payfort_payment_form\" method=\"post\" action=\"#{gateway_url}\">"
    post_data.each do |k, v|
      form = form + "<input type=\"hidden\" name=\"#{k}\" value=\"#{v}\">"
    end
    form + '<input type="submit" id="submit">'
  end

end
