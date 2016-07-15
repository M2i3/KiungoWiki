class Reports < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reports.claim.subject
  #
  def claim(report)
    @report = report
    mail to: @report.email, bcc: ENV['ADMIN_EMAIL'], subject: "Message regarding #{report.entity_type} - #{report.display_text}"
  end
end