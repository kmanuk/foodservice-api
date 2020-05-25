class PasswordsController < DeviseTokenAuth::PasswordsController
  resource_description do
    formats [:json]
    resource_id 'Password'
  end
  include Docs::Passwords

  # this action is responsible for generating password reset tokens and
  # sending emails
  def create
    unless resource_params[:email]
      return render_create_error_missing_email
    end

    # honor devise configuration for case_insensitive_keys
    if resource_class.case_insensitive_keys.include?(:email)
      @email = resource_params[:email].downcase
    else
      @email = resource_params[:email]
    end

    q = "uid = ? AND provider='email'"

    # fix for mysql default case insensitivity
    if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      q = "BINARY uid = ? AND provider='email'"
    end

    @resource = resource_class.where(q, @email).first

    @errors = nil
    @error_status = 400

    if @resource
      yield @resource if block_given?
      @resource.send_reset_password_instructions({
        email: @email,
        provider: 'email',
        redirect_url: @redirect_url,
        client_config: params[:config_name]
      })

      if @resource.errors.empty?
        return render_create_success
      else
        @errors = @resource.errors
      end
    else
      @errors = [I18n.t('devise.passwords.user_not_found', email: @email)]
      @error_status = 404
    end

    if @errors
      return render_create_error
    end
  end

  # this is where users arrive after visiting the password reset confirmation link
  def edit
    password = SecureRandom.hex.first(8)
    @resource = resource_class.reset_password_by_token({
      reset_password_token: resource_params[:reset_password_token],
      password: password,
      password_confirmation: password
    })

    if @resource && @resource.id
      @resource.send_password_change_notification(password: password)

      render text: I18n.t('devise.passwords.updated_not_active')
    else
      render text: I18n.t('devise.passwords.expire_link')
    end
  end
end
