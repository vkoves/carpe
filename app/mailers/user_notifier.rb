# Note: To test email sending locally, do UserNotifier._method_(parameters).deliver
# Ex: UserNotifier.send_signup_email(User.first).deliver
class UserNotifier < ApplicationMailer
  default from: "Carpe <do-not-reply@carpe.us>"

  # Send a signup email to the user, pass in the user object that contains the user's email address
  def send_signup_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Carpe")
  end

  # Send an email about an event invite. The user is separate to allow for
  # testing, but should generally be event_invite.user
  def event_invite_email(user, event_invite)
    @user = user
    @invite = event_invite
    @event = event_invite.event
    @date_format = "%b. %d, %Y %l:%M %p"
    mail(to: @user.email, subject: "You Have Been Invited to #{@event.name}")
  end

  # Send an email that an event a user owns or is invited to was updated
  def event_update_email(user, event, changes)
    @user = user
    @event = event
    @changes = changes
    @date_format = "%b. %d, %Y %l:%M %p"
    mail(to: @user.email, subject: "\"#{@event.name}\" Has Been Updated")
  end
end
