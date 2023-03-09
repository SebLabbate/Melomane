class UserGigsController < ApplicationController
  # before_action :set_user_gig, only: %i[index show ]

  def index
    @user_gigs = policy_scope(UserGig).all
  end

  def show
  end

  def new
  end

  def create
    @user_gig = UserGig.new
    @gig = Gig.find(params[:gig_id])
    @user_gig.gig = @gig
    @user_gig.user = current_user
    authorize @user_gig

    if @user_gig.save
      redirect_to user_gigs_path, notice: "Added to your gigs!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # private

  # def set_user_gig
  #   @user_gig = UserGig.find(params[:gig_id])
  # end

  # def user_gig_params
  #   params.require(:user_gig).permit(:gig_id)
  # end
end
