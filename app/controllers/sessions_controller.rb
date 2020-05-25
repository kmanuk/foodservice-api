class SessionsController < DeviseTokenAuth::SessionsController
  resource_description do
    formats [:json]
    resource_id 'Session'
  end
  include Docs::Sessions

  def create
    # Check
    field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

    @resource = nil
    if field
      q_value = resource_params[field]

      if resource_class.case_insensitive_keys.include?(field)
        q_value.downcase!
      end

      q = "#{field.to_s} = ? AND provider='email'"

      @resource = resource_class.where(q, q_value).first
    end

    if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
      valid_password = @resource.valid_password?(resource_params[:password])
      if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
        render_create_error_bad_credentials
        return
      end
      # create client id
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)

      @resource.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
      }

      # set role
      if @resource.respond_to?('role=') && resource_role_params.present?
        @resource.role = resource_role_params[:role]
      end

      # set token
      if @resource.respond_to?('token=') && resource_token_params.present?
        @resource.token = resource_token_params[:token]
      end

      if @resource.save
        sign_in(:user, @resource, store: false, bypass: false)

        yield @resource if block_given?

        render_create_success
      else
        render_login_error
      end
    elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
      render_create_error_not_confirmed
    else
      render_create_error_bad_credentials
    end
  end

  def destroy
    # can not log out if user has active orders
    if @resource&.has_active_orders?
      render json: { status: :unprocessable_entity, errors: ["You can't logout with active orders"] }, status: :unprocessable_entity
    else
      @resource&.inactive!
      @resource&.remove_push_token
      super
    end
  end

  private

  def render_login_error
    render json: {
      status: 'unprocessable_entity',
      errors: @resource.errors.full_messages
    }, status: :unprocessable_entity
  end

  def resource_role_params
    params.permit(:role)
  end

  def resource_token_params
    params.permit(:token)
  end
end
