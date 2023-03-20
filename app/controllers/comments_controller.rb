class CommentsController < ApplicationController
  before_action :set_user_gig, only: %i[new show create destroy_attachment]

  def index
    @comments = Comments.all.with_attached_photos
  end

  def show
  end

  def new
    @comment = Comment.new
    authorize @comment
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user_gig = @user_gig
    authorize @comment
    if @comment.save
      redirect_to user_gig_path(@comment.user_gig), notice: "Memory added!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy_attachment
    attachment = ActiveStorage::Attachment.find(params[:photo_id])
    attachment.purge
  end

  private

  def set_user_gig
    @user_gig = UserGig.find(params[:user_gig_id])
  end

  def comment_params
    params.require(:comment).permit(:content, :rating, photos: [])
  end
end
