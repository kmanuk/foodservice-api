class Api::V1::AddressesController < ApiController
  resource_description do
    formats [:json]
    api_version 'v1'
  end
  include Docs::V1::Addresses

  before_action :authenticate_user!, :set_address

  def index
    if @address
      render :show
    else
      render_errors nil, 'not found', :not_found
    end

  end

  def create
    @address ||= Address.new
    @address.assign_attributes(address_params)

    if @address.save && current_user.update_column(:address_id, @address.id)
      render :show
    else
      render_errors @address
    end
  end

  private

  def set_address
    @address = current_user.address
  end

  def address_params
    params.require(:address).permit(:location, :longitude, :latitude)
  end
end
