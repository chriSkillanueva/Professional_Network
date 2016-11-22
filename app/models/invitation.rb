class Invitation < ActiveRecord::Base
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :invite, class_name: "User", foreign_key: "invite_id"
end
