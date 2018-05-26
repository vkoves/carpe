class CreateEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.datetime :date

      t.timestamps null: false
    end
  end
end
