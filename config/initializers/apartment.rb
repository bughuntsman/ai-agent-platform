# Multi-tenancy configuration using Apartment gem
# Each tenant gets its own PostgreSQL schema for data isolation

# require 'apartment/elevators/subdomain'

# Apartment.configure do |config|
#   # Models that should live in the public schema (shared across all tenants)
#   config.excluded_models = %w[Tenant User]

#   # Tenant will be determined by subdomain
#   # Example: acme.myapp.com -> tenant: acme
#   config.tenant_names = -> { Tenant.pluck(:subdomain) }

#   # Use PostgreSQL schemas for multi-tenancy
#   config.use_schemas = true
# end

# Middleware to switch tenant based on subdomain
# Rails.application.config.middleware.use Apartment::Elevators::Subdomain
