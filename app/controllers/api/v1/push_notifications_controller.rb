class Api::V1::PushNotificationsController < ApiController
  resource_description do
    formats [:json]
    api_version 'v1'
  end
  include Docs::V1::PushNotifications

  before_action :authenticate_user!

  def index
    user = User.find user_id
    order = Order.find order_id

    # render 404 if can not find current user in selected order
    raise ActiveRecord::RecordNotFound unless order.linked_with?(current_user.id)
    # render 404 if can not find user in selected order
    raise ActiveRecord::RecordNotFound unless order.linked_with?(user.id)

    Push::Send.call(
      user: user,
      options: notification_params.to_h
    )

    render_success
  end


  def reset
    if current_user.reset_push_counter(reset_params)
      render_success
    else
      render_errors(nil)
    end
  end

  private

  def user_id
    params[:user_id]
  end

  def reset_params
    params[:type]
  end

  def order_id
    params[:order_id]
  end

  def notification_params
    custom_keys = params[:notification].try(:fetch, :custom_data, {}).keys
    params.require(:notification).
      permit(:alert, :badge, :sound, :category, :content_available, :mutable_content, custom_data: custom_keys)
  end
end
