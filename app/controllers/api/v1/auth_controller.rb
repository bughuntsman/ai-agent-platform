module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [:login, :register]

      # POST /api/v1/auth/login
      def login
        subdomain = params[:subdomain]
        email = params[:email]
        password = params[:password]

        if subdomain.blank? || email.blank? || password.blank?
          return render json: { error: 'Missing required parameters' }, status: :bad_request
        end

        tenant = Tenant.find_by(subdomain: subdomain)
        unless tenant
          return render json: { error: 'Invalid credentials' }, status: :unauthorized
        end

        user = tenant.users.find_by(email: email)
        if user&.authenticate(password)
          token = user.generate_jwt

          render json: {
            token: token,
            user: user_json(user),
            tenant: tenant_json(tenant)
          }
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/register
      # Register a new tenant with admin user
      def register
        subdomain = params[:subdomain]
        tenant_name = params[:tenant_name]
        email = params[:email]
        password = params[:password]

        if subdomain.blank? || tenant_name.blank? || email.blank? || password.blank?
          return render json: { error: 'Missing required parameters' }, status: :bad_request
        end

        ActiveRecord::Base.transaction do
          # Create tenant
          tenant = Tenant.create!(
            name: tenant_name,
            subdomain: subdomain,
            settings: {}
          )

          # Set current tenant and create admin user
          ActsAsTenant.current_tenant = tenant

          user = User.create!(
            tenant: tenant,
            email: email,
            password: password,
            role: 'admin'
          )

          token = user.generate_jwt

          ActsAsTenant.current_tenant = nil

          render json: {
            token: token,
            user: user_json(user),
            tenant: tenant_json(tenant),
            message: 'Registration successful'
          }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: 'Registration failed', details: e.message }, status: :unprocessable_entity
      end

      # GET /api/v1/auth/me
      def me
        render json: {
          user: user_json(current_user),
          tenant: tenant_json(current_tenant)
        }
      end

      private

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          created_at: user.created_at
        }
      end

      def tenant_json(tenant)
        {
          id: tenant.id,
          name: tenant.name,
          subdomain: tenant.subdomain,
          active: tenant.active
        }
      end
    end
  end
end
