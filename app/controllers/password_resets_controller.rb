class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "controllers.concerns.sent_password"
      redirect_to root_path
    else
      flash.now[:danger] = t "controllers.concerns.email_not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty? # Case (3)
      @user.errors.add(:password, t("controllers.concerns.empty"))
      render :edit
    elsif @user.update_attributes(user_params) # Case (4)
      log_in @user
      @user.update_attribute :reset_digest, nil
      flash[:success] = t "controllers.concerns.pass_reset"
      redirect_to @user
    else
      render :edit # Case (2)
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by email: params[:email]
    return if @user
    flash.now[:danger] = t "controllers.concerns.email_not_found"
    redirect_to new_password_reset_path
  end

  # Confirms a valid user.
  def valid_user
    return if @user&.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "controllers.concerns.pass_reset_expired"
    redirect_to new_password_reset_url
  end
end
