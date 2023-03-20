require 'uri'
require 'net/http'
require 'openssl'

class UserGigsController < ApplicationController
  before_action :set_user_gig, only: %i[show edit update destroy]

  def index
    @user_gigs = policy_scope(UserGig).all
  end

  def show
    @gigs = Gig.all
    @user_gigs = UserGig.all
    authorize @user_gig
    @other_gigs = find_other_genres_two(@user_gigs)
    if @other_gigs.length == 1
      @similar_gigs = @other_gigs[0]
    elsif @other_gigs.length == 2
      @similar_gigs = @other_gigs[0..1]
    else
      @similar_gigs = @other_gigs[0..2]
    end
  end

  def new
  end

  def past_gigs
    @gigs = Gig.all
    @user_gigs = policy_scope(UserGig).all
    authorize @user_gigs
    @other_gigs = find_other_genres_two(@user_gigs)
    if @other_gigs.length == 1
      @similar_gigs = @other_gigs[0]
    elsif @other_gigs.length == 2
      @similar_gigs = @other_gigs[0..1]
    else
      @similar_gigs = @other_gigs[0..2]
    end
  end

  def upcoming_gigs
    @gigs = Gig.all
    @user_gigs = policy_scope(UserGig).all
    authorize @user_gigs
    @other_gigs = find_other_genres_two(@user_gigs)
    if @other_gigs.length == 1
      @similar_gigs = @other_gigs[0]
    elsif @other_gigs.length == 2
      @similar_gigs = @other_gigs[0..1]
    else
      @similar_gigs = @other_gigs[0..2]
    end
  end

  def toggle
    @user_gig = UserGig.find(params[:id])
    @user_gig.update(attended: params[:attended])
    respond_to do |format|
      if @user_gig.update user_gig_params
        format.html { redirect_to user_gigs_path, notice: 'Gig was attended' }
        format.json { render @user_gig.json }
      else
        format.html { render :new }
        format.json { render json: @user_gig.errors, status: :unprocessable_entity }
      end
    end
    authorize @user_gig
  end

  def create
    @user_gig = UserGig.new
    @gig = Gig.find(params[:gig_id])
    @user_gig.gig = @gig
    @user_gig.user = current_user
    authorize @user_gig
    if @user_gig.save
      redirect_to dashboard_path, notice: "Added to your gigs!"
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
        format.html { redirect_to upcoming_gigs_user_gigs_path, notice: "Your gig edited" }
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

  private

  def set_user_gig
    @user_gig = UserGig.find(params[:id])
  end

  def user_gig_params
    params.require(:user_gig).permit(:comment, :attended, :user_id, gig_attributes: [:id, :name, :artist])
  end

  def find_other_genres
    new_array = []
    @gigs.each do |item|
      if item.genre == @user_gig.gig.genre && @user_gig.gig.name != item.name && item.date > Date.current
        new_array << item
      end
    end
    return new_array
  end

  def find_other_genres_two(user_gig_array)
    array = find_other_genres
    final_array = []
    array.each do |gig|
      if user_gig_array.find { |item| item.gig_id == gig.id } == nil
        final_array << gig
      end
    end
    return final_array
  end
end
