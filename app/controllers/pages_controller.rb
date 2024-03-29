class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def dashboard
    @upcoming_gigs = UserGig.all.select { |upcoming_gig| upcoming_gig.user_id == current_user.id && upcoming_gig.gig.date > DateTime.current if upcoming_gig.gig.date != nil }.last(4)
    @past_gigs = UserGig.all.select { |past_gig| past_gig.user_id == current_user.id && past_gig.gig.date < DateTime.current if past_gig.gig.date != nil }.last(4)
  end
end
