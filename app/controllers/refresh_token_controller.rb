class RefreshTokenController < ApplicationController
  before_action :authenticate_refresh_request, only: [:refresh_token]
  before_action :authenticate_request, only: [:invalidate_expired_tokens]
  before_action :is_admin, only: [:invalidate_expired_tokens]

  def refresh_token
    response_payload = generate_tokens(@current_user).merge({ message: "Token Refreshed Successfully" })

    render json: response_payload, status: :ok
  end

  def invalidate_expired_tokens
    RefreshToken.where("created_at < ?", 1.week.ago).delete_all
    render json: { message: "All Refresh Tokens Invalidated" }, status: :ok
  end

  private

  def authenticate_refresh_request
    begin
      header = request.headers["Authorization"]
      header = header.split(" ").last if header

      if !header
        return render json: { error: "Refresh Token Missing" }, status: :bad_request
      end

      decoded = decode(header)

      refresh_token_instance = RefreshToken.find(decoded["refresh_token_id"]) if decoded

      if !refresh_token_instance
        return render json: { error: "Invalid Refresh Token" }, status: :unauthorized
      end

      if refresh_token_instance.is_used
        RefreshToken.where(user_id: refresh_token_instance.user_id).update_all(is_used: true)
        return render json: { error: "Refresh Token already used." }, status: :unauthorized
      end

      refresh_token_instance.is_used = true

      if !refresh_token_instance.save
        return render json: { errors: refresh_token_instance.errors.messages }, status: :bad_request
      end

      @current_user = User.find(refresh_token_instance.user_id) if refresh_token_instance

      if !@current_user
        return render json: { error: "User not found" }, status: :not_found
      end
    rescue JWT::ExpiredSignature
      render json: { error: "Refresh Token Expired" }, status: :unauthorized
    end
  end

  def is_admin
    if !@current_user.admin
      return render json: { error: "You are not an admin" }, status: :unauthorized
    end
  end
end
