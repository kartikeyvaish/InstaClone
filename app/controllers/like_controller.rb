class LikeController < ApplicationController
  before_action :like_exists, only: [:like_a_post, :unlike_a_post]
  prepend_before_action :authenticate_request, :find_post

  def get_likes_on_post
    limit = params[:limit] || 10
    offset = params[:offset] || 0

    likes = Like.where(post_id: @post.id).limit(limit).offset(offset).order(created_at: :desc)

    cleaned_up_likes = likes.map do |like|
      like.as_json
    end

    render json: { likes: cleaned_up_likes, message: "List of all likes on post." }, status: :ok
  end

  def like_a_post
    if @is_liked
      return render json: { is_liked: true, message: "You have already liked this post." }, status: :bad_request
    end

    new_like = Like.new
    new_like.user_id = @current_user.id
    new_like.post_id = @post.id

    if new_like.save
      render json: { is_liked: true, message: "Post liked successfully." }, status: :ok
    else
      render json: { is_liked: false, errors: new_like.errors.messages }, status: :bad_request
    end
  end

  def unlike_a_post
    unless @is_liked
      return render json: { is_liked: false, message: "You have not liked this post yet." }, status: :bad_request
    end

    like = Like.where(user_id: @current_user.id, post_id: @post.id).first

    if like.blank?
      return render json: { is_liked: false, message: "Like not found." }, status: :not_found
    end

    if like.destroy
      render json: { is_liked: false, message: "Post unliked successfully." }, status: :ok
    else
      render json: { is_liked: true, errors: like.errors.messages }, status: :bad_request
    end
  end

  private

  def like_exists
    if Like.where(user_id: @current_user.id, post_id: @post.id).exists?
      @is_liked = true
    else
      @is_liked = false
    end
  end
end
