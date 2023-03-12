class UserGigsController < ApplicationController
  before_action :set_user_gig, only: %i[show edit update destroy]

  def index
    @user_gigs = policy_scope(UserGig).all
  end

  def show
  end

  def new
  end

  def past_gigs
    @user_gigs = policy_scope(UserGig).all
    @pexels_array = pexel_photos
    authorize @user_gigs
  end

  def upcoming_gigs
    @user_gigs = policy_scope(UserGig).all
    authorize @user_gigs
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

  def edit
    authorize @user_gig
  end

  def update
    authorize @user_gig
    @user_gig.user = current_user
    respond_to do |format|
      if @user_gig.update user_gig_params
        format.html { redirect_to user_gigs_path, notice: "Your gig edited" }
        format.json { render :new, status: :edited, location: @user_gig }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_gig.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @user_gig
    @user_gig.destroy
    respond_to do |format|
      format.html { redirect_to user_gig_path, notice: "Gig removed" }
      format.json { head :no_content }
    end
  end

  def pexel_photos
    client = Pexels::Client.new('41EOfTlvkrnn8r297MvVFXPjmYq2jLs9OGSGZLfrQpDRmFVXMvMJdCHO')
    photo = client.photos.search('concert').to_a
    first = photo[rand(1..12)].src
    array = []
    first.each_value do |value|
      array << value
    end
    return array
  end

  private

  def set_user_gig
    @user_gig = UserGig.find(params[:id])
  end

  def user_gig_params
    params.require(:user_gig).permit(:comment, :attended, :user_id, gig_attributes: [:id, :name, :artist])
  end
end
