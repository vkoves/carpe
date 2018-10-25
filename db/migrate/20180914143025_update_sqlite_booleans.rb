class UpdateSqliteBooleans < ActiveRecord::Migration[5.2]
  UPDATES = [
    [Group, :posts_preapproved],
    [Notification, :viewed],
    [Relationship, :confirmed],
    [User, :admin],
    [User, :public_profile],
    [UsersGroup, :accepted]
  ]

  def up
    return if Rails.env.production?

    UPDATES.each do |model, column|
      model.where("#{column} = 't'").update_all(column => 1)
      model.where("#{column} = 'f'").update_all(column => 0)
    end

    change_column_default :notifications, :viewed, 0
    change_column_default :users, :public_profile, 0
    change_column_default :users_groups, :accepted, 0
  end

  def down
    return if Rails.env.production?

    UPDATES.each do |model, column|
      model.where("#{column} = '1'").update_all(column => true)
      model.where("#{column} = '0'").update_all(column => false)
    end

    change_column_default :notifications, :viewed, false
    change_column_default :users, :public_profile, false
    change_column_default :users_groups, :accepted, false
  end
end
