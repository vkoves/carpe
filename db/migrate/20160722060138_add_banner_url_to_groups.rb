class AddBannerUrlToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :banner_image_url, :string
  end
end
