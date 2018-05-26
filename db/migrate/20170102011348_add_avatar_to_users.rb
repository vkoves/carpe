class AddAvatarToUsers < ActiveRecord::Migration[4.2]
	def self.up
	  add_attachment :users, :avatar
	end

	def self.down
	  remove_attachment :users, :avatar
	end
end
