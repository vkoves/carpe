class RepeatException < ApplicationRecord
	belongs_to :user
	has_and_belongs_to_many :events
	has_and_belongs_to_many :categories
end
