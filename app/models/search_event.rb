class SearchEvent < ApplicationRecord
  belongs_to :workspace
  validates :query, presence: true, length: { maximum: 150 }
  validates :result_count, numericality: { greater_than_or_equal_to: 0 }
end
