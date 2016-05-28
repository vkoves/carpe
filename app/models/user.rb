class User < ActiveRecord::Base
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  has_many :users_groups
  has_many :groups, :through => :users_groups
  has_many :notifications, :class_name => 'Notification', :foreign_key => 'receiver_id'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	devise :omniauthable
	validates_presence_of :name

	has_many :categories
	has_many :events
  has_many :repeat_exceptions

  ##########################
  ##### EVENT METHODS ######
  ##########################

  def current_events #return events that are currently going on
    now = Time.now.in_time_zone("Central Time (US & Canada)")
    busy_events = self.events_in_range(DateTime.now.beginning_of_day, DateTime.now.end_of_day) #get events that occur today
    busy_events = busy_events.select{|event| (event.date <= now and event.end_date >= now)} #get events going on right now
    return busy_events.sort_by(&:end_date) #return the busy events sorted by which ends soonest
  end

  def next_event #returns the next upcoming event within the next day
    now = Time.now.in_time_zone("Central Time (US & Canada)")
    upcoming_events = self.events_in_range(DateTime.now.beginning_of_day, DateTime.now.end_of_day)
    upcoming_events = upcoming_events.select{|event| (event.date > now and event.date.in_time_zone("Central Time (US & Canada)").to_date == Date.today)} #get future events that occur today
    return upcoming_events.sort_by(&:date)[0]
  end

  def is_busy? #returns whether the user is currently busy (has an event going on)
    return current_events.count > 0
  end

  def events_in_range(start_date_time, end_date_time) #returns all instances of events, including cloned version of repeating events
    #fetch not repeating events first
    event_instances = self.events.where(:date => start_date_time...end_date_time, :repeat => nil)

    #then repeating events
    self.events.where.not(repeat: nil).each do |rep_event| #get all repeating events
      event_instances.concat(rep_event.events_in_range(start_date_time, end_date_time)) #and add them to the event array
    end

    event_instances = event_instances.sort_by(&:date) #and of course sort by date

    return event_instances #and return
  end

  def get_events(user) #get events that are acessible to the user passed in
   if user == self #if a user is trying to view their own events
     return events #return all events
   end

   arr = [];

   events.each do |event|
     if event.has_access(user)
       arr.push(event)
     else
       event.name = "Private"
       event.description = ""
       event.location = ""
       arr.push(event)
     end
   end

   return arr
  end

  ##########################
  ### END EVENT METHODS ####
  ##########################


  ##########################
  ##### AVATAR METHODS #####
  ##########################

	def user_avatar(size) #returns a url to the avatar with the width in pixels
    unless self.has_avatar #if this user has no avatar, or the Google default, return the gravatar avatar
      return "http://www.gravatar.com/avatar/?d=mm"
    end

	 if image_url.present? and provider #if using google icon, add a size param
       return image_url.split("?")[0] + "?sz=" + size.to_s
	 elsif image_url.present? #otherwise just return the url
	   return image_url
	 end
	end

  def has_avatar #returns whether the user has a non-default avatar
    if image_url.present? and !(provider and image_url.include? "/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M")
        return true #if the image is present and is not the Google default, return true
    else
      return false #if the image is not present, or is a Google default return false
    end
  end

  ##########################
  ### END AVATAR METHODS ###
  ##########################

  ##########################
  ##### FRIEND METHODS #####
  ##########################

	def all_friendships() #returns an array of all friendships and friends for easy printing
    all_friends = []
    all_fships = friendships + inverse_friendships

    for ifship in all_fships
      if ifship.confirmed
        all_friends.push([ifship, ifship.other_user(self)])
      end
    end

    return all_friends
	end

	def is_friend?(user) #returns whether the passed user is a friend of this user
	  friendship = (Friendship.where(user_id: user.id, friend_id: id) || Friendship.where(user_id: id, friend_id: user.id))[0]

    if friendship and friendship.confirmed
	    return true
	  else
	    return false
	  end
	end

	def friend_status(user) #returns text indicating friendship status
	  friendship = (Friendship.where(user_id: user.id, friend_id: id))[0]
    if !friendship
      friendship = (Friendship.where(user_id: id, friend_id: user.id))[0]
    end

    if friendship
      if friendship.confirmed == true
        return "friend"
      elsif friendship.confirmed == false
        return "denied"
      else
        return "pending"
      end
    else
      return nil
    end
	end

	def mutual_friends(user) #returns mutual friends with the passed in user
	  return all_friendships.map{|f| f[1]} & user.all_friendships.map{|f| f[1]}
	end

	def friends_count() #returns the number of friends the user has
	  return all_friendships().count
	end

  ##########################
  ### END FRIEND METHODS ###
  ##########################

  ##########################
  ## GENERAL USER METHODS ##
  ##########################

  def destroy #destroys this user and all assocaited data
    categories.destroy_all #destroy all our categories
    events.destroy_all #destroy all our events as well, though cats should cover that
    notifications.destroy_all #destroy all our notifications
    friendships.destroy_all #and all our friendships
    self.delete #and then get rid of ourselves
  end

	def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
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

  ##########################
  ## END GEN USER METHODS ##
  ##########################

end
