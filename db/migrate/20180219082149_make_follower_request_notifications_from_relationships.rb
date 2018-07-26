class MakeFollowerRequestNotificationsFromRelationships < ActiveRecord::Migration[5.1]
  def self.up
    Relationship.where(confirmed: false).find_each do |relationship|
        Notification.find_or_create_by!(receiver: relationship.followed,
                                        sender: relationship.follower,
                                        entity: relationship,
                                        event: Notification.events[:follow_request])
    end
  end
end
