class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy correct_user)
  before_action :logged_in_user, only: %i(index edit update destroy
    following followers)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.activated.paginate page: params[:page],
      per_page: Settings.per_page.user
  end

  def show
    @microposts = @user.microposts.paginate page: params[:page],
      per_page: Settings.per_page.microposts
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    @user.save!
    @user.send_activation_email
    flash[:info] = t "controllers.concerns.check_email"
    redirect_to root_path
  rescue StandardError
    flash[:danger] = t "controllers.concerns.time_out"
    render :new
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "controllers.concerns.update_profile"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.delete
    flash[:success] = t "controllers.concerns.delete_user"
    redirect_to users_path
  rescue StandardError
    flash[:danger] = t "controllers.concerns.unsuccessfully_user"
    redirect_to root_path
  end

  def following
    @title = t "micropost.following"
    @user = User.find_by params[:id]
    if @user
      @users = @user.following.paginate(page: params[:page])
      render "show_follow"
    else
      flash[:danger] = t "controllers.concerns.an_error"
      redirect_to root_path
    end
  end

  def followers
    @title = t "micropost.followers"
    @user = User.find_by params[:id]
    if @user
      @users = @user.followers.paginate(page: params[:page])
      render "show_follow"
    else
      flash[:danger] = t "controllers.concerns.an_error"
      redirect_to root_path
    end
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "layouts.messenger.no_data"
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation)
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "controllers.concerns.please_lg"
    redirect_to login_path
  end

  def correct_user
    redirect_to root_path unless current_user?(@user)
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
