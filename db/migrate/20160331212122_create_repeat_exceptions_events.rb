class CreateRepeatExceptionsEvents < ActiveRecord::Migration
  def change
    create_table :repeat_exceptions_events do |t|
      t.belongs_to :repeat_exception, index: true
      t.belongs_to :event, index: true
    end
  end
end
