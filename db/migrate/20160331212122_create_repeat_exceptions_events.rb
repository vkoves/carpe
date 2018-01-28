class CreateRepeatExceptionsEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :events_repeat_exceptions, id: false do |t|
      t.belongs_to :repeat_exception, index: true
      t.belongs_to :event, index: true
    end
  end
end
