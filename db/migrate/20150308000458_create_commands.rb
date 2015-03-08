class CreateCommands < ActiveRecord::Migration
  def change
    create_table :commands do |t|
      t.integer :user_id
      t.string :key
      t.string :value
      t.timestamps null: false
    end
    add_index :commands, [:user_id, :key], :unique => true
    add_index :commands, :user_id
  end
end
