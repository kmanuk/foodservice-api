class Payments::Response < Payments::Base

  include Interactor

  before do
    @params = context[:params]
  end

  def call

    compare_signatures(@params)


    if @params[:command] == 'AUTHORIZATION' && can_be_authorized?

      case @params['response_code']
        when '02000'
          authorize_payment
        else
          @order.payment.failed!
      end
    end

    @result = @params
  end

  after do
    context.result = @result
  end

  private

  def can_be_authorized?
    find_order
    @order.payment.unpaid? || @order.payment.status == '3ds_required'
  end

  def authorize_payment
    @order.payment.authorized!
    @order.update(paid: true)
    Push::Generator.call(user: @order.seller, notification: :order_created, order: @order)
    OrderCanceletionWorker.perform_in(1.hour, @order.id, :not_approved)
  end


  def find_order
    @order = Payment.find_by(merchant_reference: @params[:merchant_reference])&.order
    unless @order
      context.fail!(errors: 'Invalid merchant_reference')
    end
  end

end
