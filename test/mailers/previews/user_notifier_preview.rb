# Preview all emails at http://localhost:3000/rails/mailers/user_notifier
# This file ONLY sets up previews for emails, all data in here is for testing
class UserNotifierPreview < ActionMailer::Preview
  def send_signup_email
    UserNotifier.send_signup_email(User.first)
  end

  def event_invite_email
    invite = EventInvite.first

    UserNotifier.event_invite_email(invite.user, invite)
  end

  def event_update_email
  	user = User.first
  	event = Event.first

  	# Change the name and start time (but don't save) for the preview
  	event.name += ' - changed';
  	event.date += 1.hour;
  	changes = event.changes

  	UserNotifier.event_update_email(user, event, changes)
  end
end
