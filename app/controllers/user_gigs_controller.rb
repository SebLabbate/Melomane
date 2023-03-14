require 'google_search_results'

class UserGigsController < ApplicationController
  before_action :set_user_gig, only: %i[show edit update destroy]

  def index
    @user_gigs = policy_scope(UserGig).all
  end

  def show
    @gigs = Gig.all
    @user_gigs = UserGig.all
    authorize @user_gig
    @artist_sum = parse_wiki_info(@user_gig.gig.artist)
    @artist_image = parse_wiki_image(@user_gig.gig.artist)
    @artist_image_b = parse_serpapi_image(@user_gig.gig.artist, 2)
    @artist_image_c = parse_serpapi_image(@user_gig.gig.artist, 3)
    @other_gigs = find_other_genres(@gigs)
    @pexels_array = pexel_photos
    @pexels_array_b = pexel_photos
    @pexels_array_c = pexel_photos
    @pexels_array_d = pexel_photos
    @pexels_array_e = pexel_photos
    other_gigs_photos
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

  private

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

  def set_user_gig
    @user_gig = UserGig.find(params[:id])
  end

  def user_gig_params
    params.require(:user_gig).permit(:comment, :attended, :user_id, gig_attributes: [:id, :name, :artist])
  end

  def parse_wiki_info(name)
    page = Wikipedia.find(name)
    if page != nil
      info = "#{page.summary.split('.')[0]}.#{page.summary.split('.')[1]}.#{page.summary.split('.')[2]}"
    else
      page = Wikipedia.find("#{name} (singer)")
      info = "#{page.summary.split('.')[0]}.#{page.summary.split('.')[1]}.#{page.summary.split('.')[2]}"
    end
    return info
  end

  def find_other_genres(array)
    new_array = []
    array.each do |item|
      if item.genre == @user_gig.gig.genre && @user_gig.gig.name != item.name && item.date > Date.current
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

  def parse_wiki_image(name)
    page = Wikipedia.find(name)
    photo = page.main_image_url
    return photo
  end

end
