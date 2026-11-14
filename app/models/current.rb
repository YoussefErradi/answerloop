class Current < ActiveSupport::CurrentAttributes
  attribute :session, :workspace, :membership
  delegate :user, to: :session, allow_nil: true
end
