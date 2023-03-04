class GigsController < ApplicationController
  def index
    @gigs = policy_scope(Gig).all
  end
end
