# The User model, which defines a unique user and all of the properties they have
class User < ApplicationRecord
  include Profile

  has_many :active_relationships,  class_name: "Relationship",
                                   foreign_key: "follower_id",
                                   dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy

  has_many :all_following, through: :active_relationships,  source: :followed # all followers, including pending
  has_many :all_followers, through: :passive_relationships, source: :follower # all followers, including pending

  has_many :users_groups, dependent: :destroy
  has_many :groups, -> { where users_groups: { accepted: true } }, through: :users_groups
  has_many :notifications, class_name: "Notification", foreign_key: "receiver_id"

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable
  validates_presence_of :name, :home_time_zone

  # when group_id is used, user_id represents the creator of a
  # category/event/exception (as opposed to its owner)
  has_many :categories, -> { where group_id: nil }
  has_many :events, -> { where group_id: nil }
  has_many :repeat_exceptions, -> { where group_id: nil }

  def send_signup_email
    UserNotifier.send_signup_email(self).deliver_now
  end

  after_create :send_signup_email

  ##########################
  ##### EVENT METHODS ######
  ##########################

  def current_events # return events that are currently going on
    events_in_range(1.day.ago, DateTime.current, home_time_zone)
      .select(&:current?).sort_by(&:end_date)
  end

  def next_event # returns the next upcoming event within the next day
    events_in_range(DateTime.current, 1.day.from_now, home_time_zone)
      .min_by(&:date)
  end

  def is_busy? # returns whether the user is currently busy (has an event going on)
    current_events.count > 0
  end

  ##########################
  ### END EVENT METHODS ####
  ##########################

  ##########################
  ##### AVATAR METHODS #####
  ##########################

  # Returns a url to the avatar with the width in pixels.
  def avatar_url(size = 256)
    return "#{image_url.split('?')[0]}?sz=#{size}" if has_google_avatar? # google avatar
    return avatar.url(size <= 60 ? :thumb : :profile) if avatar.exists? # uploaded avatar

    gravatar_url(size) # default avatar
  end

  DEFAULT_GOOGLE_AVATAR_URL = "/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M".freeze

  def has_google_avatar?
    provider.present? && image_url.present? && image_url.exclude?(DEFAULT_GOOGLE_AVATAR_URL)
  end

  # Returns whether the user has a non-default avatar.
  def has_avatar?
    avatar.exists? || has_google_avatar?
  end

  ##########################
  ### END AVATAR METHODS ###
  ##########################

  ##########################
  #### FOLLOWER METHODS ####
  ##########################

  # Follows a user.
  def follow(other_user)
    if other_user.public_profile # if the other user is a public user, auto-confirm
      active_relationships.create(followed_id: other_user.id, confirmed: true)
    else
      active_relationships.create(followed_id: other_user.id)
    end
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Confirms following (let's someone follow this user)
  def confirm_follow(other_user)
    passive_relationships.find_by(follower_id: other_user.id).confirm
  end

  def deny_follow(other_user)
    passive_relationships.find_by(follower_id: other_user.id).deny
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    if following.include?(other_user) && active_relationships.find_by(followed_id: other_user.id).confirmed # if following and confirmed
      true
    else
      false
    end
  end

  def follow_status(other_user) # returns text indicating friendship status
    if active_relationships.find_by(followed_id: other_user.id)
      if active_relationships.find_by(followed_id: other_user.id).confirmed
        "confirmed"
      else
        "pending"
      end
    end
  end

  def followers # Fetch followers that are confirmed
    passive_relationships.includes(:follower).where(confirmed: true).map(&:follower)
  end

  def followers_count # Fetch count of followers. Doesn't eager load for optimization
    passive_relationships.where(confirmed: true).size
  end

  def following # Fetch users being followed that are confirmed
    active_relationships.includes(:followed).where(confirmed: true).map(&:followed)
  end

  def following_count # Fetch count of following. Doesn't eager load for optimization
    active_relationships.where(confirmed: true).size
  end

  def followers_relationships
    passive_relationships.includes(:follower).where(confirmed: true)
  end

  def following_relationships
    active_relationships.includes(:followed).where(confirmed: true)
  end

  # returns followers of this user that the current user "knows", as in is following
  def known_followers(other_user)
    followers & other_user.followers # this finds items in both arrays
  end

  ##########################
  ### END FOLLOW METHODS ###
  ##########################

  ##########################
  ## GENERAL USER METHODS ##
  ##########################

  def destroy # destroys this user and all assocaited data
    categories.destroy_all # destroy all our categories
    events.destroy_all # destroy all our events as well, though cats should cover that
    notifications.destroy_all # destroy all our notifications
    active_relationships.destroy_all # destroy all following relationships
    passive_relationships.destroy_all # destroy all followed relationships
    delete # and then get rid of ourselves
  end

  def self.find_for_google_oauth2(access_token, _signed_in_resource = nil)
    data = access_token.info

    user = User.where(provider: access_token.provider, uid: access_token.uid).first
    if user
      return user
    else
      registered_user = User.where(email: data.email).first
      if registered_user
        return registered_user
      else
        user = User.create(name: data["name"],
                           provider: access_token.provider,
                           email: data["email"],
                           uid: access_token.uid,
                           password: Devise.friendly_token[0, 20],
                           image_url: data["image"])
      end
   end
  end

  # Return nice text for the auth provider used by this user
  def provider_name
    if provider == "google_oauth2" # if google oauth
      "Google" # return Google
    elsif provider # if we don't recognize the provider
      provider # just return it
    end
  end

  def in_group?(group)
    groups.include?(group)
  end

  ##########################
  ## END GEN USER METHODS ##
  ##########################
end
