class AddBannerToUser < ActiveRecord::Migration[4.2]
	def self.up
	  add_attachment :users, :banner
	end

	def self.down
	  remove_attachment :users, :banner
	end
end
