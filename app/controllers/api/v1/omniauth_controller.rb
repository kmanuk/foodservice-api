class Api::V1::OmniauthController < ApiController
  resource_description do
    formats [:json]
    api_version 'v1'
  end
  include Docs::V1::Omniauth

  def create
    case params[:provider]
    when 'twitter'
      twitter
    else
      render_errors(nil, 'Wrong provider', :bad_request)
    end
  end

  private

  def twitter
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = twitter_params[:access_token]
      config.access_token_secret = twitter_params[:access_token_secret]
    end

    @auth_hash = client.current_user(include_email: true).to_hash
    authorize

  rescue Twitter::Error::Unauthorized => e
    render_errors(nil, e.to_s, :unauthorized)
  rescue Twitter::Error::NotFound => e
    render_errors(nil, e.to_s, :not_found)
  rescue => e
    if e.class.name.include?('Twitter::Error')
      render_errors(nil, e.to_s)
    else
      raise e
    end
  end

  def authorize
    get_resource_from_auth_hash
    create_token_info
    set_token_on_resource

    # assign any additional (whitelisted) attributes
    extra_params = whitelisted_params
    @resource.assign_attributes(extra_params) if extra_params.present?

    if @resource.class.devise_modules.include?(:confirmable)
      # don't send confirmation email!!!
      @resource.skip_confirmation!
    end

    if @resource.save
      sign_in(:user, @resource, store: false, bypass: false)

      render json: { data: @resource.as_json }
    else
      render_errors @resource
    end
  end

  def get_resource_from_auth_hash
    # find or create user by provider and provider uid
    @resource = User.where(
      uid:      @auth_hash[:id],
      provider: params[:provider]
    ).first_or_initialize

    set_random_password if @resource.new_record?

    assign_provider_attrs # sync user info with provider

    @resource
  end

  def twitter_params
    params.permit(:access_token, :access_token_secret)
  end

  def assign_provider_attrs
    attrs = @auth_hash.slice(*OAUTH_KEYS)
    @resource.assign_attributes(attrs)
  end

  def set_random_password
    # set crazy password for new oauth users. this is only used to prevent
    # access via email sign-in.
    p = SecureRandom.urlsafe_base64(nil, false)
    @resource.password = p
    @resource.password_confirmation = p
  end

  def create_token_info
    # create token info
    @client_id = SecureRandom.urlsafe_base64(nil, false)
    @token     = SecureRandom.urlsafe_base64(nil, false)
    @expiry    = (Time.now + DeviseTokenAuth.token_lifespan).to_i
  end

  def set_token_on_resource
    @resource.tokens[@client_id] = {
      token: BCrypt::Password.create(@token),
      expiry: @expiry
    }
  end

  def whitelisted_params
    params.permit(*SIGN_UP_KEYS)
  end
end
