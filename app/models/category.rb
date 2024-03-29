class Category < ApplicationRecord
  belongs_to :user
  belongs_to :group, optional: true
  has_many :events
  has_and_belongs_to_many :repeat_exceptions

  def destroy
    events.destroy_all
    delete
  end

  # returns whether the current user can see this category
  def accessible_by?(user)
    return true if user == owner
    return true if privacy == "public"

    # must be signed in to view categories past this point
    return false if user.nil?

    # only fellow group members can see 'private' categories
    return group&.member?(user) if privacy == "private"

    # only followers can see categories with a 'follower' privacy
    return user.following?(owner) if privacy == "followers"
  end

  # returns the event with details hidden
  def private_version
    private_category = dup
    private_category.id = id # categories still need IDs even when private
    private_category.name = "Private Category"
    private_category.created_at = nil
    private_category.updated_at = nil
    private_category.color = "grey"
    private_category
  end

  def get_html_name
    name.present? ? ERB::Util.html_escape(name) : "<i>Untitled</i>"
  end

  def owner
    group || user
  end
end
