class ContactMessage
  include ActiveModel::Model

  attr_accessor :name, :email, :message, :website

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 254 }
  validates :message, presence: true, length: { minimum: 10, maximum: 2_000 }
end
