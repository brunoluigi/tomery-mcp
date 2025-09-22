class ApplicationMailer < ActionMailer::Base
  default from: "No Reply <no-reply@passionfruits.dev>"
  layout "mailer"
end
