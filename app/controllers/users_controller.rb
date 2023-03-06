class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
  end

  def destroy
    @user = User.find(params[:id])
    # session[:user_id] = nil
    @user.destroy
    # flash[:success] = "User deleted"
    redirect_to new_user_registration, status: :see_other
  end

  private

  def user_params
    params.require(:users).permit(:id)
  end
end
