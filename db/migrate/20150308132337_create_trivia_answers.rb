class CreateTriviaAnswers < ActiveRecord::Migration
  def change
    create_table :trivia_answers do |t|
      t.string :channel_id
      t.string :answer

      t.timestamps null: false
    end
    add_index :trivia_answers, :channel_id
  end
end
