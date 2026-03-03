class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :itinerary, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :category
      t.string :location
      t.decimal :price
      t.integer :duration
      t.string :image_url

      t.timestamps
    end
  end
end
