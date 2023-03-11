require "rails_helper"

describe "User Log In", type: :request do
  it "logs in a user" do
    FactoryBot.create(:user, name: "Tester Name", email: "test@gmail.com", password: "password")

    post "/auth/login", params: { user: { email: "test@gmail.com", password: "password" } }

    expect(response).to have_http_status(:ok)
  end
end

describe "No Account Test", type: :request do
  it "login without account" do
    post "/auth/login", params: { user: { email: "tester@gmail.com", password: "password" } }

    expect(response).to have_http_status(:not_found)
  end
end

describe "Invalid Password", type: :request do
  it "logs in with a invalid password" do
    FactoryBot.create(:user, name: "Tester Name", email: "tester@gmail.com", password: "password")

    post "/auth/login", params: { user: { email: "tester@gmail.com", password: "other_password" } }

    expect(response).to have_http_status(:unauthorized)
  end
end

describe "User Sign Up", type: :request do
  it "signs up a user" do
    post "/auth/signup", params: { user: { name: "Test User", email: "test@gmail.com", password: "password", password_confirmation: "password" } }

    expect(response).to have_http_status(:created)
  end
end

describe "User Sign Up Different Password", type: :request do
  it "signs up a user with different password" do
    post "/auth/signup", params: { user: { name: "Test User", email: "test@gmail.com", password: "password", password_confirmation: "other_password" } }

    expect(response).to have_http_status(:bad_request)
  end
end
