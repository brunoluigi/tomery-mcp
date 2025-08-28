class UserMailer < ApplicationMailer
  def activated(user)
    @user = user
    mail subject: "Your account is activated", to: user.email_address
  end
end
