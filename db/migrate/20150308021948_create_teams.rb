class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :slack_team_id
      t.string :slack_team_name

      t.timestamps null: false
    end
    add_index :teams, :slack_team_id
  end
end
