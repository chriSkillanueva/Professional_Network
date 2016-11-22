class User < ActiveRecord::Base
  has_many :friendships, class_name: "Friendship", foreign_key: "user_id", dependent: :destroy
  has_many :friends, through: :friendships, dependent: :destroy

  has_many :invitations, class_name: "Invitation", foreign_key: "user_id"
  has_many :invites, through: :invitations, dependent: :destroy, dependent: :destroy

  has_secure_password

  email_regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: email_regex }
  validates :password, length: { minimum: 8 }, on: :create
  validates :description, presence: true
end
