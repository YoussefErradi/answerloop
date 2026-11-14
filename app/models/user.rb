class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :restrict_with_error
  has_many :workspaces, through: :memberships
  has_many :sent_invitations, class_name: "WorkspaceInvitation", foreign_key: :invited_by_user_id, inverse_of: :invited_by, dependent: :restrict_with_error

  normalizes :email_address, with: ->(value) { value.strip.downcase }
  validates :email_address, presence: true, uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 12 }, if: -> { password.present? }
end
