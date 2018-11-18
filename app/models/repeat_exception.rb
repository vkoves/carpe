class RepeatException < ApplicationRecord
	belongs_to :user
  belongs_to :group, optional: true
	has_and_belongs_to_many :events
	has_and_belongs_to_many :categories
end
