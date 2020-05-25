json.order do
  json.partial! 'order', order: @order
end

json.payment_result @payment_result if @payment_result