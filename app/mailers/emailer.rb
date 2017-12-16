class Emailer < ActionMailer::Base
  default from: Settings.email_config.email_from

  def mailer(user,body,screenName)
    @user = user
    mail(to: @user,
         body: "#{body}",
         subject: "简画大师||#{screenName}发了一条新的哇晒")
  end

  def testM
    puts "============邮件发送================"
    mail(:to => ["zhangrq@csdn.net","ligz@csdn.net"]) do |format|
      format.text { render :text => "Hello Mikel!" }
      format.html { render :text => "<h1>Hello Mikel!</h1>" }
    end
    puts "============邮件发送end================"
  end
end
