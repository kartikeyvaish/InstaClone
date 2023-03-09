class PostController < ApplicationController
  prepend_before_action :authenticate_request
  before_action :find_post, only: [:show, :delete]
  before_action :validate_post_owner, only: [:delete]

  def get_feed
    limit = params[:limit] || 10
    offset = params[:offset] || 0

    posts = Post.all.limit(limit).offset(offset).order(created_at: :desc)

    cleaned_up_posts = posts.map do |post|
      get_post_details(post)
    end

    render json: { posts: cleaned_up_posts, message: "List of all posts." }, status: :ok
  end

  def get_own_posts
    limit = params[:limit] || 10
    offset = params[:offset] || 0

    posts = Post.where(user_id: @current_user.id).limit(limit).offset(offset).order(created_at: :desc)

    cleaned_up_posts = posts.map do |post|
      get_post_details(post)
    end

    render json: { posts: cleaned_up_posts, message: "List of all posts by current user." }, status: :ok
  end

  def create
    new_post = Post.new(new_post_params)
    new_post.user_id = @current_user.id

    if new_post.save
      render json: { post: get_post_details(new_post), message: "Post created successfully." }, status: :ok
    else
      render json: { errors: new_post.errors.messages }, status: :bad_request
    end
  end

  def show
    render json: { post: get_post_details(@post), message: "Post details." }, status: :ok
  end

  def delete
    if @post.destroy
      render json: { message: "Post deleted successfully." }, status: :ok
    else
      render json: { errors: @post.errors.messages }, status: :bad_request
    end
  end

  private

  def validate_post_owner
    unless @post.user_id == @current_user.id
      render json: { error: "You are not authorized to perform this action." }, status: :unauthorized
    end
  end

  def new_post_params
    params.require(:post).permit(:caption, :image, :location)
  end

  def get_post_details(post)
    {
      id: post[:id],
      caption: post[:caption],
      image: post[:image],
      location: post[:location],
      user_details: {
        id: post.user[:id],
        name: post.user[:name],
      },
      likes_count: post.likes.count,
      is_liked: post.likes.where(user_id: @current_user.id).present?,
      created_at: post[:created_at],
      updated_at: post[:updated_at],
    }
  end
end
