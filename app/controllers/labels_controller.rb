class LabelsController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :json
  
  def index
    respond_with current_user.labels.all
  end
  
  def lookup
    search_data = params[:q].to_s
    data = current_user.labels.only(:id,:name).where(name:/#{search_data}/).all << {id:search_data, name:search_data}
    p data.inspect
    respond_with data
  end
  
end
