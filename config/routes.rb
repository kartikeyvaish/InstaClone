Rails.application.routes.draw do
  # Auth Routes
  post "/auth/login", to: "user#login"
  post "/auth/signup", to: "user#signup"

  # Posts Routes
  get "/posts/feed", to: "post#get_feed"
  get "/posts/me", to: "post#get_own_posts"
  post "/posts", to: "post#create"
  get "/posts/:id", to: "post#show"
  delete "/posts/:id", to: "post#delete"

  # Likes Routes
  get "/likes/post/:id", to: "like#get_likes_on_post"
  post "/likes/post/:id", to: "like#like_a_post"
  delete "/likes/post/:id", to: "like#unlike_a_post"

  # Tokens
  get "/token/refresh", to: "refresh_token#refresh_token"
end
