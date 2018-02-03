#   enum privacy: { public: 0, private: 1, secret: 2 }
class AddPrivacyToGroups < ActiveRecord::Migration[4.2]

  def change
    add_column :groups, :privacy, :integer, default: 0
  end
end
