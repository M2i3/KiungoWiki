class PublishersController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :json
  
  def index
    respond_with Publisher.all
  end
  
  def lookup
    search_data = params[:q].to_s 
    respond_with Publisher.only(:name).where(name:/#{search_data}/).all.map {|p| {id:p.name, name:p.name}} << {id:search_data, name:search_data}
  end
  
end
