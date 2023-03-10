class CommentController < ApplicationController
  before_action :find_post, only: [:get_comments_on_a_post, :create]
  before_action :find_comment, only: [:edit, :delete]
  before_action :is_comment_owner, only: [:edit]
  before_action :can_delete_comment, only: [:delete]
  prepend_before_action :authenticate_request

  def get_comments_on_a_post
    limit = params[:limit] || 10
    offset = params[:offset] || 0

    comments = Comment.where(post_id: @post.id).limit(limit).offset(offset).order(created_at: :desc)

    cleaned_comments = comments.map do |comment_item|
      comment_item.as_json
    end

    render json: { comments: cleaned_comments, message: "List of all comments on post." }, status: :ok
  end

  def create
    comment = Comment.new(
      user_id: @current_user.id,
      post_id: @post.id,
      body: params[:comment],
    )

    if comment.save
      render json: comment.as_json, status: :ok
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def delete
    if @comment.destroy
      render json: { message: "Comment deleted successfully." }, status: :ok
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    @comment.body = params[:comment]
    @comment.is_edited = true

    if @comment.save
      render json: @comment.as_json, status: :ok
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def find_comment
    @comment = Comment.find(params[:id])

    if @comment.blank?
      return render json: { message: "Comment not found." }, status: :not_found
    end
  end

  def is_comment_owner
    unless @comment.user.id == @current_user.id
      render json: { message: "You are not authorized to edit this comment" }, status: :unauthorized
    end
  end

  def can_delete_comment
    unless @comment.user_id == @current_user.id || @comment.post.user_id == @current_user.id
      render json: { message: "You are not authorized to delete this comment" }, status: :unauthorized
    end
  end
end
