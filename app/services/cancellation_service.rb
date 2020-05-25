class CancellationService

  def self.call(reason: nil, order:, who:)
    params = {order: order,
              status: order.status,
              who: who,
              reason: reason}

    params[:user] = case params[:who]
                      when 'driver'
                        order.driver
                      when 'seller'
                        order.seller
                      else
                        nil
                    end
    Cancellation.create(params)
  end

end

