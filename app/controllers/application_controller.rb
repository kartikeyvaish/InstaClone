class ApplicationController < ActionController::API
  include JsonWebToken

  rescue_from ActionController::ParameterMissing, with: :handle_missing_params

  private

  def authenticate_request
    begin
      header = request.headers["Authorization"]
      header = header.split(" ").last if header

      if !header
        return render json: { error: "Access Token Missing" }, status: :bad_request
      end

      decoded = decode(header)
      @current_user = User.find(decoded["user_id"]) if decoded

      if !@current_user
        return render json: { error: "User not found" }, status: :not_found
      end
    rescue JWT::ExpiredSignature
      render json: { error: "Access Token Expired" }, status: :unauthorized
    end
  end

  def generate_tokens(user)
    new_refresh_instance = RefreshToken.new(user_id: user.id, is_used: false)

    if !new_refresh_instance.save
      return render json: { errors: new_refresh_instance.errors.messages }, status: :bad_request
    end

    access_token = encode({ user_id: user.id })
    refresh_token = encode({ refresh_token_id: new_refresh_instance.id }, 7.days.from_now)

    return { access_token: access_token, refresh_token: refresh_token }
  end

  def find_post
    begin
      @post = Post.find(params[:id])
    rescue ActiveRecord::RecordNotFound => exception
      render json: { error: exception.message }, status: :not_found
    end
  end

  def handle_missing_params(exception)
    render json: { ok: false, error: exception.message }, status: :bad_request
  end
end
