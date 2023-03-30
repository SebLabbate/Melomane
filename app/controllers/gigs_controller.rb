require 'wikipedia'
require 'rspotify'
require 'uri'
require 'net/http'
require 'openssl'


class GigsController < ApplicationController
  before_action :set_gig, only: %i[show edit update]

  def index
    @gig = Gig.new
    @search_params = params[:query].downcase unless params[:query] == nil
    @search_params_two = params[:querycity].downcase unless params[:querycity] == nil
    @search_params_three = params[:querygenre].downcase unless params[:querycity] == nil
    if @search_params == ""
      @search_params = nil
    end
    if @search_params_two == ""
      @search_params_two = nil
    end
    if @search_params_three == ""
      @search_params_three = nil
    end
    @gigs = policy_scope(Gig).all
    @user_gigs = UserGig.all
    if @search_params != nil && @search_params_two == nil && @search_params_three == nil
      @events_array = find_events_array_by_name(@search_params)
    elsif @search_params != nil && @search_params_two != nil && @search_params_three == nil
      @events_array = find_events_array_by_city_and_name(@search_params_two, @search_params)
    elsif @search_params == nil && @search_params_two != nil && @search_params_three == nil
      @events_array = find_events_array_by_city(@search_params_two)
    elsif @search_params != nil && @search_params_two != nil && @search_params_three != nil
      @events_array = find_events_array_by_city_name_and_genre(@search_params_two, @search_params, @search_params_three)
    elsif @search_params == nil && @search_params_two != nil && @search_params_three != nil
      @events_array = find_events_array_by_city_and_genre(@search_params_two, @search_params_three)
    elsif @search_params != nil && @search_params_two == nil && @search_params_three != nil
      @events_array = find_events_array_by_name_and_genre(@search_params, @search_params_three)
    elsif @search_params == nil && @search_params_two == nil && @search_params_three != nil
      @events_array = find_events_array_by_genre(@search_params_three)
    else
      @events_array = nil
    end
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
    @audio_one = return_audio(@gig.song_one)
    @audio_two = return_audio(@gig.song_two)
    @audio_three = return_audio(@gig.song_three)
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
      if params[:page] == "gigs"
        redirect_to gig_path(@gig)
      else
        redirect_to dashboard_path
      end
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

  def find_event_venue(event)
    if event["_embedded"] != nil && event["_embedded"]["venues"] != nil
      event_venue = event["_embedded"]["venues"][0]["name"]
    else
      event_venue = nil
    end
    return event_venue
  end

  def find_event_artist(event)
    if event["_embedded"] != nil && event["_embedded"]["attractions"] != nil
      artist_name = event["_embedded"]["attractions"][0]["name"]
    else
      artist_name = nil
    end
    return artist_name.downcase unless artist_name == nil
  end

  def find_event_date(event)
    event_date = event["dates"]["start"]["dateTime"]
    return event_date
  end

  private

  def set_markers
    @markers =
      [{
        lat: @gig.latitude,
        lng: @gig.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: { gig: @gig })
      }]
  end

  def find_other_genres
    new_array = []
    @gigs.each do |item|
      if item.genre != nil && item.date != nil
        if item.genre == @gig.genre && @gig.name != item.name && item.date > Date.current
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

  def gig_params
    p params
    params.require(:gig).permit(:name, :artist, :venue, :genre, :user_id, :photo, :date, :private, :latitude, :longitude, :tickets, :photo_url_two)
  end

  def set_gig
    @gig = Gig.find(params[:id])
  end

  def find_events_array_by_name(name)
    url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&keyword=#{name}&classificationName=music&size=200")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    events = response.read_body
    gigs = JSON.parse(events)
    if gigs["_embedded"] != nil
      events_hash = gigs["_embedded"]
      events_hash_two = events_hash["events"]
    else
      events_hash_two = nil
    end
    return events_hash_two
  end

  def find_events_array_by_city(city)
    url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&locale=*&city=#{city}&classificationName=music&size=200")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    events = response.read_body
    gigs = JSON.parse(events)
    if gigs["_embedded"] != nil
      events_hash = gigs["_embedded"]
      events_hash_two = events_hash["events"]
    else
      events_hash_two = nil
    end
    return events_hash_two
  end

  def find_events_array_by_city_and_name(city, name)
    url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&locale=*&city=#{city}&keyword=#{name}&classificationName=music&size=200")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    events = response.read_body
    gigs = JSON.parse(events)
    if gigs["_embedded"] != nil
      events_hash = gigs["_embedded"]
      events_hash_two = events_hash["events"]
    else
      events_hash_two = nil
    end
    return events_hash_two
  end

  def find_events_array_by_city_and_genre(city, genre)
    url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&locale=*&city=#{city}&classificationName=#{genre}&size=200")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    events = response.read_body
    gigs = JSON.parse(events)
    if gigs["_embedded"] != nil
      events_hash = gigs["_embedded"]
      events_hash_two = events_hash["events"]
    else
      events_hash_two = nil
    end
    return events_hash_two
  end

  def find_events_array_by_genre(genre)
    url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&classificationName=#{genre}&size=200")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    events = response.read_body
    gigs = JSON.parse(events)
    if gigs["_embedded"] != nil
      events_hash = gigs["_embedded"]
      events_hash_two = events_hash["events"]
    else
      events_hash_two = nil
    end
    return events_hash_two
  end


  def find_events_array_by_city_name_and_genre(city, name, genre)
    url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&locale=*&city=#{city}&keyword=#{name}&classificationName=#{genre}&size=200")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    events = response.read_body
    gigs = JSON.parse(events)
    if gigs["_embedded"] != nil
      events_hash = gigs["_embedded"]
      events_hash_two = events_hash["events"]
    else
      events_hash_two = nil
    end
    return events_hash_two
  end


  def find_events_array_by_name_and_genre(name, genre)
    url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&keyword=#{name}&classificationName=#{genre}&size=200")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    events = response.read_body
    gigs = JSON.parse(events)
    if gigs["_embedded"] != nil
      events_hash = gigs["_embedded"]
      events_hash_two = events_hash["events"]
    else
      events_hash_two = nil
    end
    return events_hash_two
  end

  def get_track_id(artist_first_name, artist_last_name, song_name)
    url = URI("https://soundcloud-scraper.p.rapidapi.com/v1/search/tracks?term=#{artist_first_name}%20#{artist_last_name}%20#{song_name}&size=200")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'bb141578ecmsh6d28efe29ac7316p11e81cjsn2a1ed1dbaddf'
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
    request["X-RapidAPI-Key"] = 'bb141578ecmsh6d28efe29ac7316p11e81cjsn2a1ed1dbaddf'
    request["X-RapidAPI-Host"] = 'soundcloud-scraper.p.rapidapi.com'
    response = http.request(request)
    body = response.read_body
    track_url = body.split('"')[11]
    return track_url
  end

  def split_artist_first_name(name)
    if name != nil
      split_name = name.split(" ")
      if split_name.length == 2
        first_name = split_name[0].downcase
      else
        first_name = name.downcase
      end
    else
      first_name = nil
    end
    return first_name
  end

  def split_artist_last_name(name)
    if name != nil
      split_name = name.split(" ")
      if split_name.length == 2
        last_name = split_name[1].downcase
      else
        last_name = nil
      end
    else
      last_name = nil
    end
    return last_name
  end

  def return_audio(track_name)
    first_name = split_artist_first_name(@gig.artist)
    last_name = split_artist_last_name(@gig.artist)
    track_id = get_track_id(first_name, last_name, track_name)
    track_url = get_track_url(track_id)
    return track_url
  end


end
