class Emailer < ActionMailer::Base
  default from: Settings.email_config.email_from

  def mailer(user,body,screenName)
    @user = user
    mail(to: @user,
         body: "#{body}",
         subject: "简画大师||#{screenName}发了一条新的哇晒")
  end

end
