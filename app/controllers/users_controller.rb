class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    redirect_to dashboard_path
  end

  def destroy
    @user = User.find(params[:id])
    # session[:user_id] = nil
    @user.destroy
    # flash[:success] = "User deleted"
    redirect_to new_user_registration, status: :unprocessible_entity
  end

  private

  def user_params
    params.require(:users).permit(:id)
  end
end
