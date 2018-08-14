class AddColumnsToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :custom_url, :string
    add_column :groups, :banner_file_name, :string
    add_column :groups, :banner_content_type, :string
    add_column :groups, :banner_file_size, :integer
    add_column :groups, :banner_updated_at, :datetime
  end
end
