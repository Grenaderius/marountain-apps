class CommentsController < ApplicationController
  # GET /comments
  def index
    comments = Comment.includes(:user)
    render json: comments, include: {
      user: { only: [:id, :name] }
    }
  end

  # POST /comments
  def create
    comment = Comment.new(comment_params)
    if comment.save
      render json: comment, include: {
        user: { only: [:id, :name] }
      }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:app_id, :user_id, :comment, :rating)
  end
end
