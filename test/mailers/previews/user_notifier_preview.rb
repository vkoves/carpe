# Preview all emails at http://localhost:3000/rails/mailers/user_notifier
# This file ONLY sets up previews for emails, all data in here is for testing
class UserNotifierPreview < ActionMailer::Preview
	def send_signup_email
		UserNotifier.send_signup_email(User.first)
	end

	def event_invite_email
		UserNotifier.event_invite_email(User.first)
	end
end
