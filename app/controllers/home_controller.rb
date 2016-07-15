class HomeController < ApplicationController
  def index
    redirect_to search_path(:q=>params[:q]) if params[:q]
  end

  def site_plan
  end
  
  def report
    if request.post? 
      @report = ReportEntity.new params[:report_entity]
      if @report.valid?
        #url = self.send(@@url_method.to_sym,@@release)
        Reports.claim(@report).deliver
        redirect_to @report.entity_url, notice: I18n.t('report.email_sent')
        puts "redirecting"
      end
    else
      @report = ReportEntity.new(entity_url: params[:return_to], display_text: params[:display_text], entity_type: params[:entity_type])
      if current_user
        @report.email = current_user.email
      end 
    end
  end
end
