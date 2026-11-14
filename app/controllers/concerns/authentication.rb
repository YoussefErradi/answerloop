module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  private

  def authenticated?
    resume_session.present?
  end

  def resume_session
    Current.session ||= Session.includes(:user).find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id].present?
  end

  def require_authentication
    return if resume_session
    redirect_to new_session_path, alert: "Please sign in to continue."
  end

  def start_new_session_for(user)
    # Rotate the session cookie whenever credentials are authenticated.
    Current.session&.destroy!
    Current.session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
    cookies.signed.permanent[:session_id] = {
      value: Current.session.id, httponly: true, same_site: :lax,
      secure: Rails.env.production?
    }
  end

  def terminate_session
    Current.session&.destroy!
    cookies.delete(:session_id)
    Current.reset
  end
end
