class Orders::Base
  private

  def validate_belongs_seller
    if @order.seller != @user
      context.fail!(errors: I18n.t('errors.base.validate_belongs_seller'))
    end
  end

  def validate_belongs_driver
    if @order.driver != @user
      context.fail!(errors: I18n.t('errors.base.validate_belongs_driver'))
    end
  end

  def order_params
    @params.require(:order).permit(:delivery_type,
                                   :type,
                                   :payment_type,
                                   line_items: [:item_id,
                                                :quantity],
                                   payment_attributes: [:card_number,
                                                        :card_holder_name,
                                                        :token_name,
                                                        :merchant_reference,
                                                        :expiry_date,
                                                        :card_bin,
                                                        :ip_address],
                                   address_attributes: [:location,
                                                        :latitude,
                                                        :longitude])
  end

  def amount_available?(line_items)
    result = line_items.map do |li|
      item = find_item(li[:item_id])
      li[:quantity] <= item.amount
    end

    context.fail!(errors: I18n.t('errors.base.amount_available')) unless result.all?
  end

  def find_seller
    id = order_params[:line_items].first[:item_id]
    Item.find_by(id: id)&.user
  end

  def find_items &block
    data = order_params[:line_items]
    context.fail!(errors: I18n.t('errors.base.find_items')) unless data.present?
    data.map do |line_item|
      item = find_item(line_item[:item_id])
      block.call(item, line_item[:quantity].to_i)
    end
  end

  def find_item(id)
    item = Item.find_by(id: id)
    item ? item : context.fail!(errors: I18n.t('errors.base.find_item'))
  end

end
