class TicketMessage < ApplicationRecord
  belongs_to :ticket
  belongs_to :author, class_name: "User", optional: true
  enum :kind, { reply: 0, note: 1 }, default: :reply
  validates :body, presence: true, length: { maximum: 20_000 }
  validate :staff_author_in_workspace

  private

  def staff_author_in_workspace
    errors.add(:author, "must be a workspace member") if author && !ticket.workspace.memberships.exists?(user_id: author.id)
    errors.add(:author, "is required for notes") if note? && author.nil?
  end
end
