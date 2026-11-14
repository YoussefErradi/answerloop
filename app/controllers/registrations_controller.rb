class RegistrationsController < ApplicationController
  skip_before_action :require_authentication

  def new
    return redirect_to root_path if authenticated?
    @user = User.new
  end

  def create
    return redirect_to root_path if authenticated?
    @user = User.new(registration_params)
    if @user.save
      start_new_session_for(@user)
      redirect_to new_workspace_path, notice: "Welcome! Create your first workspace."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
