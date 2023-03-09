require "jwt"

SECRET = ENV["JWT_TOKEN"]

module JsonWebToken
  extend ActiveSupport::Concern

  def encode(payload, exp = 30.minutes.from_now)
    payload[:exp] = exp.to_i

    JWT.encode(payload, SECRET)
  end

  def decode(token)
    decoded = JWT.decode(token, SECRET)

    return decoded[0]
  end
end
