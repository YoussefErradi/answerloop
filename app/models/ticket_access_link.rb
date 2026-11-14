class TicketAccessLink < ApplicationRecord
  belongs_to :ticket
  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def self.issue!(ticket)
    token = SecureRandom.urlsafe_base64(32)
    ticket.ticket_access_links.create!(token_digest: Digest::SHA256.hexdigest(token), expires_at: 30.minutes.from_now)
    token
  end

  def self.consume!(token)
    digest = Digest::SHA256.hexdigest(token.to_s)
    transaction do
      link = lock.find_by(token_digest: digest)
      return nil unless link && link.used_at.nil? && link.expires_at.future?
      link.update!(used_at: Time.current)
      link.ticket
    end
  end
end
