class CreateItineraries < ActiveRecord::Migration[8.1]
  def change
    create_table :itineraries do |t|
      t.references :chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.decimal :budget_max
      t.integer :duration_max

      t.timestamps
    end
  end
end
