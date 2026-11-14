class CustomerContact < ApplicationRecord
  belongs_to :workspace
  has_many :tickets, dependent: :restrict_with_error
  normalizes :email, with: ->(value) { value.strip.downcase }
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: { scope: :workspace_id }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
