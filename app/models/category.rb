class Category < ActiveRecord::Base
	belongs_to :user
	has_many :events
	
	def destroy
    events.destroy_all
    self.delete
	end
end
