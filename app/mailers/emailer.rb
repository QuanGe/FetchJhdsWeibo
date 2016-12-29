class Emailer < ActionMailer::Base
  default from: "zhang_ru_quan@163.com"

  def mailer(user,body,screenName)
    @user = user
    mail(to: @user,
         body: "#{body}",
         subject: "#{screenName}发了一条新的哇晒")
  end

end
