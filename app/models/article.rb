class Article < ApplicationRecord
  SEARCH_VECTOR = "to_tsvector('english', coalesce(articles.title, '') || ' ' || coalesce(articles.search_body, ''))".freeze

  belongs_to :workspace
  belongs_to :category, optional: true
  belongs_to :author, class_name: "User"
  has_rich_text :body

  enum :status, { draft: 0, published: 1 }, default: :draft
  validates :title, presence: true, length: { maximum: 180 }
  validates :status, presence: true
  validates :slug, presence: true, uniqueness: { scope: :workspace_id }
  validates :summary, length: { maximum: 500 }
  validate :category_in_workspace
  validate :published_has_body
  before_validation :assign_slug, on: :create
  before_validation :prepare_publication
  before_save :refresh_search_body

  scope :publicly_visible, -> { published.where("published_at <= ?", Time.current) }

  def self.search(query)
    value = query.to_s.strip.first(150)
    return none if value.blank?
    where("#{SEARCH_VECTOR} @@ websearch_to_tsquery('english', ?)", value)
      .order(Arel.sql(sanitize_sql_array(["ts_rank(#{SEARCH_VECTOR}, websearch_to_tsquery('english', ?)) DESC", value])))
  end

  private

  def assign_slug
    self.slug ||= "#{title.to_s.parameterize[0, 65].presence || 'article'}-#{SecureRandom.hex(3)}"
  end

  def prepare_publication
    self.published_at ||= Time.current if published?
    self.published_at = nil if draft?
  end

  def refresh_search_body
    self.search_body = body.to_plain_text.to_s
  end

  def category_in_workspace
    errors.add(:category, "must belong to this workspace") if category && category.workspace_id != workspace_id
  end

  def published_has_body
    errors.add(:body, "can't be blank when published") if published? && body.to_plain_text.blank?
  end
end
