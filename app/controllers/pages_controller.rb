class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def dashboard
    # @user_gigs = UserGig.all
    @upcoming_gigs = UserGig.all.select { |upcoming_gig| upcoming_gig.user_id == current_user.id && upcoming_gig.gig.date > Date.current }.last(3)
    @past_gigs = UserGig.all.select { |past_gig| past_gig.user_id == current_user.id && past_gig.gig.date < Date.current }.last(3)
    @pexels_array = pexel_photos
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
end
