class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]

  def new
    redirect_to root_path if authenticated?
  end

  def create
    user = User.authenticate_by(email_address: params[:email_address].to_s.strip.downcase, password: params[:password].to_s)
    if user
      start_new_session_for(user)
      redirect_to root_path, notice: "Signed in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Signed out."
  end
end
