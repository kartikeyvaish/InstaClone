class UserController < ApplicationController
  include BCrypt

  wrap_parameters :user, include: [:name, :email, :password, :password_confirmation]

  def login
    user = User.find_by(email: login_params[:email])
    password = login_params[:password]

    if user == nil
      return render json: { error: "Account with this Email does not exist." }, status: :not_found
    end

    if !user.authenticate(password)
      return render json: { error: "Invalid Password" }, status: :unauthorized
    end

    response_payload = generate_tokens(user).merge({ message: "Login Successful" })

    render json: response_payload, status: :ok
  end

  def signup
    user = User.new(sign_up_params)

    if !user.save
      return render json: { errors: user.errors.messages }, status: :bad_request
    end

    response_payload = generate_tokens(user).merge({ message: "Sign Up Successful" })

    render json: response_payload, status: :created
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
