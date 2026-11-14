class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "hello@answerloop.local")
  layout "mailer"
end
