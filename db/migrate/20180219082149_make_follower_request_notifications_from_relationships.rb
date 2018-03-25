class MakeFollowerRequestNotificationsFromRelationships < ActiveRecord::Migration[5.1]
  def self.up
    Relationship.where(confirmed: false).find_each do |relationship|
        Notification.find_or_create_by!(receiver_id: relationship.followed_id,
                                        sender_id: relationship.follower_id,
                                        object_id: relationship.id,
                                        event: Notification.events[:follow_request])
    end
  end
end
