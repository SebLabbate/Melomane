class GigsController < ApplicationController
  # before_action :set_gig

  def index
    @gigs = policy_scope(Gig).all
  end

  def new
    @gig = Gig.new
    authorize @gig
  end

  def create
    @gig = Gig.new(gig_params)
    @gig.user = current_user
    if @gig.save
      @user_gig = UserGig.new
      @user_gig.user = current_user
      @user_gig.gig = @gig
      @user_gig.save
      redirect_to user_gigs_path
    else
      render :new, status: :unprocessable_entity
    end
    authorize @gig
  end

  private

  def gig_params
    params.require(:gig).permit(:name, :artist, :venue, :genre, :user_id, :date, :private)
  end

  def set_gig
    @gig = Gig.find(params[:id])
  end
end
