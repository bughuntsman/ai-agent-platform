# == Schema Information
#
# Table name: users (public schema)
#
#  id              :bigint           not null, primary key
#  tenant_id       :bigint           not null
#  email           :string           not null
#  password_digest :string           not null
#  role            :string           default("member"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_and_tenant_id  (email,tenant_id) UNIQUE
#  index_users_on_tenant_id            (tenant_id)
#

class User < ApplicationRecord
  has_secure_password

  # Associations
  belongs_to :tenant

  # Validations
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :role, inclusion: { in: %w[admin member] }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  # Callbacks
  before_validation :normalize_email

  # Scopes
  scope :admins, -> { where(role: 'admin') }
  scope :members, -> { where(role: 'member') }

  # Instance methods
  def admin?
    role == 'admin'
  end

  def generate_jwt
    payload = {
      user_id: id,
      tenant_id: tenant_id,
      tenant_subdomain: tenant.subdomain,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, ENV['JWT_SECRET_KEY'])
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end
end
