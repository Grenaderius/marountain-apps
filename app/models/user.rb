class User < ApplicationRecord
  has_secure_password

  has_many :purchases
  has_many :bought_apps, through: :purchases, source: :app

  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: " needs to be active" }
  validates :password, presence: true, length: { minimum: 6 }
end
