class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    comments = Comment.includes(:user)
    render json: comments, include: { user: { only: [:id, :name, :email] } }
  end

  def create
    # Перевірка чи юзер вже коментував цей застосунок
    existing = Comment.find_by(app_id: comment_params[:app_id], user_id: comment_params[:user_id])

    if existing
      return render json: { error: "You already left a review for this app" }, status: :forbidden
    end

    comment = Comment.new(comment_params)

    if comment.save
      comment = Comment.includes(:user).find(comment.id)
      render json: comment, include: { user: { only: [:id, :name, :email] } }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /comments/:id
  def destroy
    comment = Comment.find(params[:id])

    # авторизація: юзер може видаляти тільки свій коментар
    if comment.user_id != params[:user_id].to_i
      return render json: { error: "Not allowed" }, status: :forbidden
    end

    comment.destroy
    render json: { message: "Comment deleted" }
  end

  def update
    comment = Comment.find(params[:id])

    if comment.user_id != params[:user_id].to_i
      return render json: { error: "Not allowed" }, status: :forbidden
    end

    if comment.update(comment_params)
      render json: comment, include: { user: { only: [:id, :name, :email] } }
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:app_id, :user_id, :comment, :rating)
  end
end
