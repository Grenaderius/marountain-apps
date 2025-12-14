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

  def show
    app = App.find_by(id: params[:id])
    return render json: { error: "App not found" }, status: :not_found unless app

    render json: {
      id: app.id,
      name: app.name,
      description: app.description,
      photo_url: drive_thumbnail(app.photo_path),
      apk_url: drive_download(app.apk_path),
      is_game: app.is_game,
      cost: app.cost,
      size: app.size,
      android_min_version: app.android_min_version,
      ram_needed: app.ram_needed,
      rating: app.comments.any? ? app.comments.average(:rating).to_f.round(1) : 0,
      dev: app.dev ? { id: app.dev.id, email: app.dev.email } : nil,
      comments: app.comments.includes(:user).map do |c|
        {
          id: c.id,
          comment: c.comment,
          rating: c.rating,
          user_id: c.user_id,
          created_at: c.created_at,
          sentiment: SentimentService.analyze(c.comment),
          user: {
            id: c.user.id,
            email: c.user.email
          }
        }
      end
    }
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