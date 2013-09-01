class Reports < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reports.claim.subject
  #
  def claim(params)
    @greeting = "Hi"
    @params = params
    mail to: ENV['ADMIN_EMAIL'], cc: params[:email]
  end
end
