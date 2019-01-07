class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("mailers.user.account_activation")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("mailers.user.pass_reset")
  end
end
