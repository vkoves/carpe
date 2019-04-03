# Migration sourced from Devise add :confirmable guide -
# https://github.com/plataformatec/devise/wiki/How-To:-Add-:confirmable-to-Users/217abb19bc0b76a8de26b0252296625ef660f016#create-a-new-migration

class AddConfirmableToDevise < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_index :users, :confirmation_token, unique: true

    # We DO NOT mark all existing users as confirmed, as we want to force them
    # to confirm their emails
  end

  def down
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at
  end
end
