class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  def as_json(options = {})
    super(options.merge({ except: [:user_id, :post_id] })).merge({ "user_details" => user.as_json })
  end
end
