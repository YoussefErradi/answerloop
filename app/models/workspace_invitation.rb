class WorkspaceInvitation < ApplicationRecord
  belongs_to :workspace
  belongs_to :invited_by, class_name: "User", foreign_key: :invited_by_user_id, inverse_of: :sent_invitations

  enum :role, { admin: 1, editor: 2, agent: 3 }
  normalizes :email, with: ->(value) { value.strip.downcase }
  validates :role, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :not_already_member, on: :create
  before_validation :create_token, on: :create
  before_validation :default_expiration, on: :create

  attr_reader :raw_token

  def self.find_using_token(raw)
    return nil unless raw.is_a?(String) && raw.length.between?(40, 128)
    find_by(token_digest: Digest::SHA256.hexdigest(raw))
  end

  def usable?
    accepted_at.nil? && expires_at.future?
  end

  private

  def create_token
    return if token_digest.present?
    @raw_token = SecureRandom.urlsafe_base64(32)
    self.token_digest = Digest::SHA256.hexdigest(@raw_token)
  end

  def default_expiration
    self.expires_at ||= 7.days.from_now
  end

  def not_already_member
    return if workspace.nil? || email.blank?
    if workspace.users.where(email_address: email).exists?
      errors.add(:email, "already belongs to this workspace")
    end
  end
end
