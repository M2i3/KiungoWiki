class LabelsController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :json
  
  def index
    respond_with current_user.labels.all
  end
  
  def lookup
    search_data = params[:q].to_s 
    respond_with current_user.labels.only(:name).where(name:/#{search_data}/).all.map {|l| {id:l.name, name:l.name}} << {id:search_data, name:search_data}
  end
  
end
