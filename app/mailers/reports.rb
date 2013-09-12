class Reports < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reports.claim.subject
  #
  def claim(entity, entity_name, url, params)
    @greeting = "Hi"
    @params = params
    @entity = entity
    @entity_name = entity_name
    @url = url
    mail to: ENV['ADMIN_EMAIL'], cc: params[:email], subject: "Removal Request for #{entity.class} - #{entity_name}"
  end
end
