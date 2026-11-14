class Membership < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  enum :role, { owner: 0, admin: 1, editor: 2, agent: 3 }, default: :agent
  validates :user_id, uniqueness: { scope: :workspace_id }
  validates :role, presence: true

  def can_manage_members?
    owner? || admin?
  end
end
