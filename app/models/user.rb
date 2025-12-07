class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "повинна бути дійсною email-адресою" }
  validates :password, presence: true, length: { minimum: 6 }
end
