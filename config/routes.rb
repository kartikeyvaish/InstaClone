Rails.application.routes.draw do
  # Auth Routes
  post "/auth/login", to: "user#login"
  post "/auth/signup", to: "user#signup"

  # Posts Routes
  get "/posts/me", to: "post#get_own_posts"
  post "/posts", to: "post#create"
  get "/posts/:id", to: "post#show"

  # Tokens
  get "/token/refresh", to: "refresh_token#refresh_token"
end
