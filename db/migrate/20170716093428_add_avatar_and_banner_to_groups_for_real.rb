class AddAvatarAndBannerToGroupsForReal < ActiveRecord::Migration
  def self.up
    # apparently add_attachment does more than just add these columns, so this just removes
    # the columns that were entered manually in a previous migration.
    columns = %i(banner_file_name banner_content_type banner_file_size banner_updated_at
                 avatar_file_name avatar_content_type avatar_file_size avatar_updated_at)
    columns.each { |col| remove_column :groups, col }

    add_attachment :groups, :avatar
    add_attachment :groups, :banner
  end

  def self.down
    remove_attachment :groups, :avatar
    remove_attachment :groups, :banner
  end
end
