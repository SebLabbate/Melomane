require 'uri'
require 'net/http'
require 'openssl'

class UserGigsController < ApplicationController
  before_action :set_user_gig, only: %i[show edit update destroy]
  # before_action :set_gig

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
    @audio_one = return_audio(@user_gig.gig.song_one)
    @audio_two = return_audio(@user_gig.gig.song_two)
    @audio_three = return_audio(@user_gig.gig.song_three)
  end

  def new
    raise
  end

  def past_gigs
    @genre = params[:genre]
    @venue = params[:venue]
    @artist = params[:artist]

    @genre_gig = ""
    @venue_gig = ""
    @artist_gig = ""
    @user_gigs = policy_scope(UserGig).all
    authorize @user_gigs

    query = ""

    if @genre.present?
      @genre_gig = "gigs.genre = '#{@genre}'"
    end

    if @venue.present?
      @venue_gig = "gigs.venue = '#{@venue}'"
    end

    if @artist.present?
      @artist_gig = "gigs.artist = '#{@artist}'"
    end

    array = [@genre_gig, @venue_gig, @artist_gig]

    array.each do |gig|
      if query == "" && gig != ""
        query += gig
      elsif gig != ""
        query += " AND #{gig}"
      end
    end

    if query == ""
      @user_gigs = policy_scope(UserGig.joins(:gig)).all
    else
      @user_gigs = policy_scope(UserGig.joins(:gig)).where(query)
    end
  end

  def upcoming_gigs
    @user_gigs = policy_scope(UserGig).all
    authorize @user_gigs
    @user_gigs = @user_gigs.select { |user_gig| user_gig.gig.date > DateTime.current if user_gig.gig.date != nil }
    @markers = @user_gigs.map do |user_gig|
      if user_gig.gig.longitude != nil
        {
          lat: user_gig.gig.latitude,
          lng: user_gig.gig.longitude,
          info_window_html: render_to_string(partial: "popup", locals: {user_gig: user_gig})
        }
      end
    end
  end

  # def toggle
  #   @user_gig = UserGig.find(params[:id])
  #   respond_to do |format|
  #     if @user_gig.update!(attended: params[:attended])
  #       format.html { redirect_to past_gigs_user_gigs_path, notice: 'Gig was attended' }
  #       format.json { render @user_gig } # { render :attended, location: @user_gig }
  #     else
  #       format.html { render :new, notice: "error" }
  #       format.json { render json: @user_gig.errors, status: :unprocessable_entity }
  #     end
  #   end
  #   authorize @user_gig
  # end

  def create
    @user_gig = UserGig.new
    @gig = Gig.find(params[:gig_id])
    @user_gig.gig = @gig
    @user_gig.user = current_user
    authorize @user_gig
    if @user_gig.save
      redirect_to upcoming_gigs_user_gigs_path, notice: "Added to your gigs!"
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
        format.html { redirect_to user_gig_path(@user_gig), notice: "Your gig edited" }
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
    return redirect_to request.referrer if request.referrer.present?

    if params[:page] == "user_gigs/past_gigs"
      redirect_to past_gigs_user_gigs_path, status: :see_other
    elsif params[:page] == "upcoming_gigs"
      redirect_to upcoming_gigs_path, status: :see_other
    else
      redirect_to dashboard_path, status: :see_other
    end
  end

  private

  def set_user_gig
    @user_gig = UserGig.find(params[:id])
  end


  def set_gig
    @gig = Gig.find(params[:id])
  end

  def user_gig_params
    params.require(:user_gig).permit(:comment, :attended, :user_id, :photo, gig_attributes: [:id, :artist, :venue, :genre, :date])
  end

  def find_other_genres
    new_array = []
    @gigs.each do |item|
      if item.genre != nil && item.date != nil
        if item.genre == @user_gig.gig.genre && @user_gig.gig.name != item.name && item.date > Date.current
          new_array << item
        end
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

  def get_track_id(artist_first_name, artist_last_name, song_name)
    url = URI("https://soundcloud-scraper.p.rapidapi.com/v1/search/tracks?term=#{artist_first_name}%20#{artist_last_name}%20#{song_name}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = ENV.fetch('RAPID_API_KEY')
    request["X-RapidAPI-Host"] = 'soundcloud-scraper.p.rapidapi.com'
    response = http.request(request)
    string = response.read_body
    track_id_with_extras = string.split('"')[16]
    if track_id_with_extras != nil
      track_id_incomplete = track_id_with_extras.split(':')
      track_id = track_id_incomplete[1].split(',')
      track_id_two = track_id[0]
      return track_id_two
    else
      return nil
    end
  end
  def get_track_url(track_id)
    url = URI("https://soundcloud-scraper.p.rapidapi.com/v1/track/metadata?track=#{track_id}&download=sq")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = ENV.fetch('RAPID_API_KEY')
    request["X-RapidAPI-Host"] = 'soundcloud-scraper.p.rapidapi.com'
    response = http.request(request)
    body = response.read_body
    track_url = body.split('"')[11]
    return track_url
  end

  def split_artist_first_name(name)
    split_name = name.split(" ")
    if split_name.length == 2
      first_name = split_name[0].downcase
    else
      first_name = name.downcase
    end
    return first_name
  end

  def split_artist_last_name(name)
    split_name = name.split(" ")
    if split_name.length == 2
      last_name = split_name[1].downcase
    else
      last_name = nil
    end
    return last_name
  end

  def return_audio(track_name)
    first_name = split_artist_first_name(@user_gig.gig.artist)
    last_name = split_artist_last_name(@user_gig.gig.artist)
    track_id = get_track_id(first_name, last_name, track_name)
    track_url = get_track_url(track_id)
    return track_url
  end

end
