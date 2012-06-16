class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome_email(user)
    @user = user
    @url  = "http://127.0.0.1:3000/subscribe/#{@user.subscription_code}"
    mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end
end
