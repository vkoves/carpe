class UserNotifier < ApplicationMailer
  default from: "Carpe <do-not-reply@carpe.us>"

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Carpe")
  end
end
