class User < ApplicationRecord
  has_secure_password

  has_many :posts, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  before_validation :downcase_email

  def downcase_email
    self.email = email.downcase
  end

  def as_json(options = {})
    super(options.merge({ except: [:email, :admin, :password_digest, :created_at, :updated_at] }))
  end
end
