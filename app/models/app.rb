class App < ApplicationRecord
  belongs_to :dev, class_name: "User", foreign_key: "dev_id", optional: true
  has_many :comments
  has_many :purchases
end