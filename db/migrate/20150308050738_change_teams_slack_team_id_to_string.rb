class ChangeTeamsSlackTeamIdToString < ActiveRecord::Migration
  def change
    change_column :teams, :slack_team_id, :string
  end
end
