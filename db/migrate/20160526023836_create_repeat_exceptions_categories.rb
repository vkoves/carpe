class CreateRepeatExceptionsCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories_repeat_exceptions, id: false do |t|
      t.belongs_to :repeat_exception, index: true
      t.belongs_to :category, index: true
    end
  end
end
