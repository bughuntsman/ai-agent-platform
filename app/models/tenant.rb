# == Schema Information
#
# Table name: tenants
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  subdomain    :string           not null
#  settings     :jsonb            not null
#  active       :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_tenants_on_subdomain  (subdomain) UNIQUE
#

class Tenant < ApplicationRecord
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :subdomain, presence: true,
                        uniqueness: { case_sensitive: false },
                        format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }

  # Associations
  has_many :users, dependent: :destroy

  # Callbacks
  before_validation :normalize_subdomain
  after_create :create_tenant_schema

  # Scopes
  scope :active, -> { where(active: true) }

  # Instance methods
  def switch_tenant
    ActsAsTenant.current_tenant = self
  end

  def reset_tenant
    ActsAsTenant.current_tenant = nil
  end

  private

  def normalize_subdomain
    self.subdomain = subdomain.to_s.downcase.strip if subdomain.present?
  end

  def create_tenant_schema
    # With acts_as_tenant, we don't need to create separate schemas
    # Each tenant's data is isolated by the tenant_id foreign key
    Rails.logger.info("Tenant #{subdomain} created successfully")
  end
end
