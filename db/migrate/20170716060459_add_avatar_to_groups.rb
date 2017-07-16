class AddAvatarToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :avatar_file_name, :string
    add_column :groups, :avatar_content_type, :string
    add_column :groups, :avatar_file_size, :integer
    add_column :groups, :avatar_updated_at, :datetime
  end
end
