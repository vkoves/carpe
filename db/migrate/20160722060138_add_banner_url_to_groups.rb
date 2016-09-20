class AddBannerUrlToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :banner_image_url, :string
  end
end
