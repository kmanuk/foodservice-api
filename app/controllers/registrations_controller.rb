class RegistrationsController < DeviseTokenAuth::RegistrationsController

  resource_description do
    formats [:json]
    resource_id 'Authentication'
  end
  include Docs::Registrations

  def update
    if @resource
      if @resource.send(resource_update_method, account_update_params)
        yield @resource if block_given?
        render_update_success
      else
        render_update_error
      end
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  protected

  def render_create_error
    render json: {
      status: 'unprocessable_entity',
      errors: @resource.errors.full_messages
    }, status: :unprocessable_entity
  end

  def render_update_error
    render json: {
      status: 'unprocessable_entity',
      errors: @resource.errors.full_messages
    }, status: :unprocessable_entity
  end
end
