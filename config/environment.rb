# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  port:           ENV['MAILGUN_SMTP_PORT'],
  address:        ENV['MAILGUN_SMTP_SERVER'],
  user_name:      ENV['MAILGUN_SMTP_LOGIN'],
  password:       ENV['MAILGUN_SMTP_PASSWORD'],
  domain:         'teach.mmibordeaux.com',
  authentication: :plain,
}
ActionMailer::Base.delivery_method = :smtp
