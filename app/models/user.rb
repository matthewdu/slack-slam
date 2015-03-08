class User < ActiveRecord::Base
  belongs_to :team

  validates :slack_name, :slack_user_id, :team_id, :access_token, :presence => true
end
