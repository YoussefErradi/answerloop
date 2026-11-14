class Workspace < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :workspace_invitations, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :search_events, dependent: :destroy
  has_many :customer_contacts, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_many :audit_events, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
  before_validation :assign_slug, on: :create

  private

  def assign_slug
    return if slug.present?
    prefix = name.to_s.parameterize.presence || "workspace"
    self.slug = "#{prefix[0, 45]}-#{SecureRandom.hex(4)}"
  end
end
