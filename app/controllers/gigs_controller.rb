require 'wikipedia'
class GigsController < ApplicationController
  before_action :set_gig, only: %i[show edit update]


  def index
    if params[:query].present?
      @gigs = policy_scope(Gig.search_by_artist_and_venue(params[:query]))
    else
      @gigs = policy_scope(Gig)
      @pexels_array = pexel_photos
    end
  end

  def show
    authorize @gig
    @artist_sum = parse_wiki_info(@gig.artist)
    @artist_image = parse_wiki_image(@gig.artist)
    @gigs = Gig.all
    @other_gigs = find_other_genres(@gigs)
    @pexels_array = pexel_photos
    @pexels_array_b = pexel_photos
    @pexels_array_c = pexel_photos
    other_gigs_photos
    @artist_image_b = parse_serpapi_image(@gig.artist, 2)
    @artist_image_c = parse_serpapi_image(@gig.artist, 3)
    @user_gigs = UserGig.all
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


  def parse_wiki_info(name)
    page = Wikipedia.find(name)
    if page != nil
      info = "#{page.summary.split('.')[0]}.#{page.summary.split('.')[1]}.#{page.summary.split('.')[2]}."
    else
      page = Wikipedia.find("#{name} (singer)")
      info = "#{page.summary.split('.')[0]}.#{page.summary.split('.')[1]}.#{page.summary.split('.')[2]}."
    end
    return info
  end

  def find_other_genres(array)
    new_array = []
    array.each do |item|
      if item.genre == @gig.genre && @gig.name != item.name && item.date > Date.current
        new_array << item
      end
    end
    return new_array
  end

  def other_gigs_photos
    if @other_gigs.length > 0
      @genre_image_a = parse_wiki_image(@other_gigs[0].artist)
    end
    if @other_gigs.length > 1
      @genre_image_b = parse_wiki_image(@other_gigs[1].artist)
    end
    if @other_gigs.length > 2
      @genre_image_c = parse_wiki_image(@other_gigs[2].artist)
    end
    if @other_gigs.length > 3
     @genre_image_d = parse_wiki_image(@other_gigs[3].artist)
    end
    if @other_gigs.length > 4
      @genre_image_e = parse_wiki_image(@other_gigs[4].artist)
    end
    if @other_gigs.length > 5
      @genre_image_f = parse_wiki_image(@other_gigs[5].artist)
    end
  end

  def gig_params
    params.require(:gig).permit(:name, :artist, :venue, :genre, :user_id, :date, :private)
  end

  def set_gig
    @gig = Gig.find(params[:id])
  end


  def parse_wiki_image(name)
    page = Wikipedia.find(name)
    photo = page.main_image_url
    return photo
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

  def parse_serpapi_image(name, number)
    params = {
      q: name,
      tbm: "isch",
      api_key: "e39ea7280a6e3bbfec7c0f49409964674caaff3d39777d6c05ac14cfeab4be7f"
    }
    search = GoogleSearch.new(params)
    related_searches = search.get_hash[:images_results]
    return related_searches[number][:thumbnail]
  end

end
