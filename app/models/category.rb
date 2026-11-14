class Category < ApplicationRecord
  belongs_to :workspace
  has_many :articles, dependent: :nullify

  validates :name, presence: true, length: { maximum: 80 }
  validates :slug, presence: true, uniqueness: { scope: :workspace_id }
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  before_validation :assign_slug, on: :create

  private

  def assign_slug
    self.slug ||= "#{name.to_s.parameterize.presence || 'category'}-#{SecureRandom.hex(3)}"
  end
end
