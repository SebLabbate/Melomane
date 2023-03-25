require 'wikipedia'
require 'rspotify'
require 'uri'
require 'net/http'
require 'openssl'

class GigsController < ApplicationController
  before_action :set_gig, only: %i[show edit update]

  def index
    if params[:query].present?
      @gigs = policy_scope(Gig.search_by_artist_and_venue(params[:query]))
    else
      @gigs = policy_scope(Gig)
    end
    @user_gigs = UserGig.all
  end

  def show
    authorize @gig
    @gigs = Gig.all
    @user_gigs = UserGig.all
    @other_gigs = find_other_genres_two(@user_gigs)
    if @other_gigs.length == 1
      @similar_gigs = @other_gigs[0]
    elsif @other_gigs.length == 2
      @similar_gigs = @other_gigs[0..1]
    elsif @other_gigs.length > 2
      @similar_gigs = @other_gigs[0..2]
    else
      @similar_gigs = nil
    end
    set_markers
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
      redirect_to dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
    authorize @gig
  end

  def edit
    authorize @gig
  end

  def update
    authorize @gig
    @gig.user = current_user
    respond_to do |format|
      if @gig.update gig_params
        format.html { redirect_to user_gigs_path, notice: "Gig edited" }
        format.json { render :edit, status: :edited, location: @gig }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gig.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_markers
    @markers =
      [{
        lat: @gig.latitude,
        lng: @gig.longitude
      }]
  end

  def find_other_genres
    new_array = []
    @gigs.each do |item|
      if item.genre == @gig.genre && @gig.name != item.name && item.date > Date.current
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

  def gig_params
    params.require(:gig).permit(:name, :artist, :venue, :genre, :user_id, :date, :private)
  end

  def set_gig
    @gig = Gig.find(params[:id])
  end
end
