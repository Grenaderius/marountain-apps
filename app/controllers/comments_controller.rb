class CommentsController < ApplicationController
  # Повертає всі коментарі
  def index
    comments = Comment.all
    render json: comments
  end

  # Створює новий коментар
  def create
    comment = Comment.new(comment_params)
    if comment.save
      render json: comment, status: :created
    else
      render json: comment.errors, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:app_id, :user_id, :comment, :rating)
  end
end
