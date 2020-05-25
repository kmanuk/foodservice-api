class Api::V1::UsersController < ApiController
  resource_description do
    formats [:json]
    api_version 'v1'
  end
  include Docs::V1::Users

  before_action :authenticate_user!, :find_user

  def show
  end

  private

  def find_user
    @user = User.find_by!(id: params[:id])
  end

end
