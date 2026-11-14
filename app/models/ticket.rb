class Ticket < ApplicationRecord
  belongs_to :workspace
  belongs_to :customer_contact
  belongs_to :assignee, class_name: "User", optional: true
  has_many :ticket_messages, dependent: :destroy
  has_many :ticket_access_links, dependent: :destroy
  has_many :audit_events, dependent: :nullify

  enum :status, { open: 0, pending: 1, resolved: 2 }, default: :open
  enum :priority, { low: 0, normal: 1, high: 2 }, default: :normal
  validates :subject, presence: true, length: { maximum: 180 }
  validates :status, :priority, presence: true
  validate :relations_in_workspace
  before_validation :set_resolved_at

  def staff_members
    workspace.memberships.includes(:user).reject(&:editor?).map(&:user)
  end

  private

  def relations_in_workspace
    errors.add(:customer_contact, "must belong to this workspace") if customer_contact && customer_contact.workspace_id != workspace_id
    errors.add(:assignee, "must be a support team member") if assignee && !workspace.memberships.exists?(user_id: assignee.id, role: %i[owner admin agent])
  end

  def set_resolved_at
    self.resolved_at = resolved? ? (resolved_at || Time.current) : nil
  end
end
