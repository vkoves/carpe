class CreateRepeatExceptions < ActiveRecord::Migration
  def change
    create_table :repeat_exceptions do |t|
      t.string :name
      t.date :start
      t.date :end

      t.timestamps null: false
    end
  end
end
