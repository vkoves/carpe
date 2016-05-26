class CreateRepeatExceptionsCategories < ActiveRecord::Migration
  def change
    create_table :categories_repeat_exceptions, id: false do |t|
      t.belongs_to :repeat_exception, index: true
      t.belongs_to :category, index: true
    end
  end
end
