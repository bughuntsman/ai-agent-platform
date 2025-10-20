class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_request
  before_action :set_tenant

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from LlmService::LlmError, with: :llm_error

  private

  def authenticate_request
    authenticate_with_http_token do |token, _options|
      begin
        decoded = JWT.decode(token, ENV['JWT_SECRET_KEY'], true, algorithm: 'HS256')
        @current_user_id = decoded[0]['user_id']
        @current_tenant_id = decoded[0]['tenant_id']
        @current_tenant_subdomain = decoded[0]['tenant_subdomain']
        true
      rescue JWT::DecodeError, JWT::ExpiredSignature
        false
      end
    end || render_unauthorized
  end

  def set_tenant
    return unless @current_tenant_subdomain

    tenant = Tenant.find_by(subdomain: @current_tenant_subdomain)
    if tenant
      ActsAsTenant.current_tenant = tenant
    else
      render json: { error: 'Tenant not found' }, status: :not_found
    end
  end

  def current_user
    @current_user ||= User.find(@current_user_id)
  end

  def current_tenant
    @current_tenant ||= Tenant.find(@current_tenant_id)
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { error: exception.message, details: exception.record&.errors }, status: :unprocessable_entity
  end

  def llm_error(exception)
    render json: { error: 'LLM service error', message: exception.message }, status: :service_unavailable
  end
end
