
#The User model, which defines a unique user and all of the properties they have
class User < ApplicationRecord
  include Profile

  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  has_many :all_following, through: :active_relationships,  source: :followed #all followers, including pending
  has_many :all_followers, through: :passive_relationships, source: :follower #all followers, including pending

  has_many :users_groups, dependent: :destroy
  has_many :groups, -> { where users_groups: { accepted: true } }, :through => :users_groups
  has_many :notifications, :class_name => 'Notification', :foreign_key => 'receiver_id'

  has_many :event_invites_received, class_name: 'EventInvite',
                                    foreign_key: :user_id,
                                    dependent: :destroy

  has_many :event_invites_sent, class_name: 'EventInvite',
                                foreign_key: 'sender_id'

  has_many :events_invited_to, through: :event_invites_received, source: :event

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

  def next_event #returns the next upcoming event within the next day
    events_in_range(DateTime.current, 1.day.from_now, home_time_zone)
      .min_by(&:date)
  end

  def is_busy? #returns whether the user is currently busy (has an event going on)
     current_events.count > 0
  end

  ##########################
  ### END EVENT METHODS ####
  ##########################


  ##########################
  ##### AVATAR METHODS #####
  ##########################

  # Returns a url to the avatar with the width in pixels.
	def avatar_url(size)
    return "#{image_url.split("?")[0]}?sz=#{size}" if has_google_avatar? # google avatar
    return avatar.url(size <= 60 ? :thumb : :profile) if avatar.exists? # uploaded avatar
    gravatar_url(size) # default avatar
	end

  DEFAULT_GOOGLE_AVATAR_URL = "/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M"

  def has_google_avatar?
    provider.present? and image_url.present? and image_url.exclude?(DEFAULT_GOOGLE_AVATAR_URL)
  end

  # Returns whether the user has a non-default avatar.
  def has_avatar?
    avatar.exists? or has_google_avatar?
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
    if following.include?(other_user) and active_relationships.find_by(followed_id: other_user.id).confirmed #if following and confirmed
      return true
    else
      return false
    end
  end

  def follow_status(other_user) #returns text indicating friendship status
    if active_relationships.find_by(followed_id: other_user.id)
      if active_relationships.find_by(followed_id: other_user.id).confirmed
        return "confirmed"
      else
        return "pending"
      end
    else
      return nil
    end
  end

  def followers # Fetch followers that are confirmed
    return passive_relationships.includes(:follower).where(:confirmed => true).map{|r| r.follower}
  end

  def followers_count # Fetch count of followers. Doesn't eager load for optimization
    return passive_relationships.where(:confirmed => true).size
  end

  def following # Fetch users being followed that are confirmed
    return active_relationships.includes(:followed).where(:confirmed => true).map{|r| r.followed}
  end

  def following_count # Fetch count of following. Doesn't eager load for optimization
    return active_relationships.where(:confirmed => true).size
  end

  def followers_relationships
    passive_relationships.includes(:follower).where(:confirmed => true)
  end

  def following_relationships
    active_relationships.includes(:followed).where(:confirmed => true)
  end

  # returns followers of this user that the current user "knows", as in is following
  def known_followers(other_user)
    return followers & other_user.followers # this finds items in both arrays
  end

  ##########################
  ### END FOLLOW METHODS ###
  ##########################

  ##########################
  ## GENERAL USER METHODS ##
  ##########################

  def destroy #destroys this user and all assocaited data
    categories.destroy_all #destroy all our categories
    events.destroy_all #destroy all our events as well, though cats should cover that
    notifications.destroy_all #destroy all our notifications
    active_relationships.destroy_all # destroy all following relationships
    passive_relationships.destroy_all # destroy all followed relationships
    self.delete #and then get rid of ourselves
  end

	def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info

    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      return user
    else
      registered_user = User.where(:email => data.email).first
      if registered_user
        return registered_user
      else
        user = User.create(name: data["name"],
          provider:access_token.provider,
          email: data["email"],
          uid: access_token.uid ,
          password: Devise.friendly_token[0,20],
          image_url: data["image"]
        )
      end
   end
	end

  #Return nice text for the auth provider used by this user
  def provider_name
    if provider == "google_oauth2" #if google oauth
      return "Google" #return Google
    elsif provider #if we don't recognize the provider
      return provider #just return it
    else
      return nil
    end
  end

  def in_group?(group)
    groups.include?(group)
  end

  ##########################
  ## END GEN USER METHODS ##
  ##########################

  ##########################
  ##     MISC METHODS     ##
  ##########################

  # Convert the user into a hash with the least data needed to show search
  # Recall that clients can see the JSON with a bit of inspection, so only
  # public information should be included here
  def convert_to_json
    user_obj = {} #create a hash representing the user

    # Required fields for search/tokenInput - name and image url
    user_obj[:name] = self.name
    user_obj[:image_url] = self.avatar_url(50)
    user_obj[:model_name] = "User" # specify what type of object this is (used for site search, which handles many object types)

    user_obj #and return the user
  end

  # Ranks a collection of users for a given search query
  def self.rank(users, query)
    query = query.downcase

    users.sort {|a,b| b.rank(query) <=> a.rank(query) } # return users by rank descending (hence sort is flipped)
  end

  # Ranks the user based on the query
  # The ranking prioritizes the first name starting with the query
  # then the middle/last name starting with the query
  # and finally the query being included at all (handled by SQL)
  def rank(query)
    score = 0 # default score is 0

    if name.downcase.starts_with?(query)
      score = 2
    elsif name.downcase.include?(" " + query)
      score = 1
    end

    return score
  end

  ##########################
  ##   END MISC METHODS   ##
  ##########################


end
