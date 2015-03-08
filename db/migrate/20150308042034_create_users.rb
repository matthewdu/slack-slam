class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :slack_name
      t.string :slack_user_id
      t.integer :team_id
      t.string :access_token
      t.timestamps null: false
    end

    add_index :users, :team_id
    add_index :users, :slack_user_id
  end
end
