class AuditEvent < ApplicationRecord
  belongs_to :workspace
  belongs_to :ticket, optional: true
  belongs_to :actor, class_name: "User", optional: true
  validates :action, presence: true
end
