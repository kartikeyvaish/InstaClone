class Post < ApplicationRecord
  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  def as_json(options = {})
    super(options.merge({ except: [:user_id] })).merge({
      "user_details" => user.as_json,
      "likes_count" => likes.count,
    })
  end
end
