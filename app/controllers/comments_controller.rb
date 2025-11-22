class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    comments = Comment.includes(:user)
    render json: comments, include: { user: { only: [:id, :name, :email] } }
  end

  def create
    comment = Comment.new(comment_params)

    if comment.save
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

  private

  def comment_params
    params.require(:comment).permit(:app_id, :user_id, :comment, :rating)
  end
end
