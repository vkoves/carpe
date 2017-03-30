#The User model, which defines a unique user and all of the properties they have
class User < ActiveRecord::Base
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  has_many :all_following, through: :active_relationships,  source: :followed #all followers, including pending
  has_many :all_followers, through: :passive_relationships, source: :follower #all followers, including pending

  has_many :users_groups
  has_many :groups, :through => :users_groups
  has_many :notifications, :class_name => 'Notification', :foreign_key => 'receiver_id'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	devise :omniauthable
	validates_presence_of :name, :home_time_zone

	has_many :categories
	has_many :events
  has_many :repeat_exceptions

  # Attach the avatar image. -quality [0-100] sets quality, -strip removes meta data, -layers optimize optimizes gif layers
  has_attached_file :avatar, styles: {
    thumb: '60x60#',
    profile: '150x150#'
  }, :convert_options => {
    :thumb => "-quality 75 -strip -layers optimize", :profile => "-quality 75 -strip -layers optimize"}

  # Validate the attached avatar is an image and is under 3 Megabytes
  validates_attachment :avatar, content_type: {content_type: /\Aimage\/.*\Z/}, size: { in: 0..3.megabytes }

  has_attached_file :banner, styles: {
    desktop: {geometry: '1500x200#', animated: false},
    mobile: {geometry: '500x200#', animated: false}
  }, :convert_options => {
    :desktop => "-quality 75 -strip", :mobile => "-quality 50 -strip" }

  # Validate the attached banner photo is an image and is under 5 Megabytes
  validates_attachment :banner, content_type: {content_type: /\Aimage\/.*\Z/}, size: { in: 0..5.megabytes }

  after_create :send_signup_email

  def send_signup_email
    UserNotifier.send_signup_email(self).deliver
  end

  # Validate the custom_url ...
  REGEX_VALID_URL_CHARACTERS = /\A[a-zA-Z0-9_\-]*\Z/
  REGEX_USER_ID = /\A\d+\Z/

  validates :custom_url,
            format: { with: REGEX_VALID_URL_CHARACTERS,
                      message: 'must be alphanumeric' },
            allow_blank: true,
            uniqueness: true,
            length: { maximum: 64 }

  validates :custom_url,
            format: { without: REGEX_USER_ID,
                      message: 'cannot be an integer'}

  def has_custom_url?
    !custom_url.to_s.empty?
  end

  def to_param
    has_custom_url? ? custom_url : id
  end

  ##########################
  ##### EVENT METHODS ######
  ##########################

  def current_events #return events that are currently going on
    now = Time.now.in_time_zone("Central Time (US & Canada)")
    dt_now = DateTime.now
    busy_events = self.events_in_range(dt_now.beginning_of_day, dt_now.end_of_day) #get events that occur today
    busy_events = busy_events.select{|event| (event.date <= now and event.end_date >= now)} #get events going on right now
    return busy_events.sort_by(&:end_date) #return the busy events sorted by which ends soonest
  end

  def next_event #returns the next upcoming event within the next day
    now = Time.now.in_time_zone("Central Time (US & Canada)")
    dt_now = DateTime.now
    upcoming_events = self.events_in_range(dt_now.beginning_of_day, dt_now.end_of_day)
    upcoming_events = upcoming_events.select{|event| (event.date > now and event.date.in_time_zone("Central Time (US & Canada)").to_date == Date.today)} #get future events that occur today
    return upcoming_events.sort_by(&:date)[0]
  end

  def is_busy? #returns whether the user is currently busy (has an event going on)
    return current_events.count > 0
  end

  def events_in_range(start_date_time, end_date_time) #returns all instances of events, including cloned version of repeating events
    #fetch not repeating events first
    event_instances = events.where(:date => start_date_time...end_date_time, :repeat => nil)

    #then repeating events
    events.includes(:repeat_exceptions, category: :repeat_exceptions).where.not(repeat: nil).each do |rep_event| #get all repeating events
      event_instances.concat(rep_event.events_in_range(start_date_time, end_date_time)) #and add them to the event array
    end

    event_instances = event_instances.sort_by(&:date) #and of course sort by date

    return event_instances #and return
  end

  def get_events(user) #get events that are acessible to the user passed in
   return events.includes(:repeat_exceptions) if user == self #if a user is trying to view their own events, return all events

   events_array = [];

   events.includes(:repeat_exceptions).each do |event| #for each event
     event.has_access?(user) ? events_array.push(event) : events_array.push(event.private_version) #push the normal or private version
   end

   return events_array
  end

  def get_categories(user) #get categories that are acessible to the user passed in
    return categories if user == self #if a user is viewing their own categories, return all

    categories_array = [];

    categories.each do |category| #for each category
      category.has_access?(user) ? categories_array.push(category) : categories_array.push(category.private_version) #push the normal or private version
    end

    return categories_array
  end

  ##########################
  ### END EVENT METHODS ####
  ##########################


  ##########################
  ##### AVATAR METHODS #####
  ##########################

	def user_avatar(size) #returns a url to the avatar with the width in pixels
    unless self.has_avatar #if this user has no avatar, or the Google default, return the gravatar avatar
      return "https://www.gravatar.com/avatar/?d=mm"
    end

    if provider
      return image_url.split("?")[0] + "?sz=" + size.to_s
    else
      if size <= 60 # if image request is 60px wide or less, use thumb, which is 60px wide
        return avatar.url(:thumb)
      else # otherwise use profile, which is 150px wide
        return avatar.url(:profile)
      end
    end
	end

  def has_avatar #returns whether the user has a non-default avatar
    if (image_url.present? and provider and !image_url.include? "/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M") or avatar.exists?
        return true #if the image is present and is not the Google default, return true
    else
      return false #if the image is not present, or is a Google default return false
    end
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

  # TEMP - Forces following, only used for converting from friends to followers
  def force_follow(other_user)
    active_relationships.create(followed_id: other_user.id, confirmed: true)
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

  ##########################
  ## END GEN USER METHODS ##
  ##########################

end
