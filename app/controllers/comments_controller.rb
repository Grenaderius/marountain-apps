class CommentsController < ApplicationController
  before_action :authorize_request, except: [:index, :show]

  def index
    comments = Comment.includes(:user)

    result = comments.map do |comment|
      sentiment = SentimentService.analyze(comment.comment)

      {
        id: comment.id,
        comment: comment.comment,
        rating: comment.rating,
        app_id: comment.app_id,
        created_at: comment.created_at,
        sentiment: sentiment,
        user: {
          id: comment.user.id,
          name: comment.user.name,
          email: comment.user.email
        }
      }
    end

    render json: result
  end

  def create
    existing = Comment.find_by(app_id: comment_params[:app_id], user_id: @current_user.id)
    return render json: { error: "You already left a review for this app" }, status: :forbidden if existing

    comment = Comment.new(comment_params.merge(user_id: @current_user.id))
    if comment.save
      comment = Comment.includes(:user).find(comment.id)
      render json: comment, include: { user: { only: [:id, :name, :email] } }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    comment = Comment.find(params[:id])
    return render json: { error: "Not allowed" }, status: :forbidden unless comment.user_id == @current_user.id

    if comment.update(comment_params)
      render json: comment, include: { user: { only: [:id, :name, :email] } }
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    comment = Comment.find(params[:id])
    return render json: { error: "Not allowed" }, status: :forbidden unless comment.user_id == @current_user.id
    comment.destroy
    render json: { message: "Comment deleted" }
  end

  private

  def comment_params
    params.require(:comment).permit(:app_id, :comment, :rating)
  end
end