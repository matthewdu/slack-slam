class Team < ActiveRecord::Base
  has_many :users

  validates :slack_team_id, :slack_team_name, :presence => true
end
