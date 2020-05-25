class ApiController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  layout 'api'

  protected

  def pagination page, limit, total, total_pages
    @pagination = OpenStruct.new(
      page: page,
      limit: limit,
      total: total,
      total_pages: total_pages
    )
  end

  def sanitize_params
    sanitize_params = params.to_hash.reject { |k, v| v.blank? }
    ActionController::Parameters.new underscore_keys sanitize_params
  end

  def record_not_found
    head :not_found
  end

  private


  def render_success data = {}, status = :ok
    render json: { status: status, data: data }, status: status
  end

  def underscore_keys value
    case value
    when Array
      value.map { |v| underscore_keys v }
    when Hash
      Hash[value.map { |k, v| [k.to_s.underscore.to_sym,  underscore_keys(v)] }]
    else
      value
    end
  end
end
