class WorksController < ApplicationController

  def index
    @works = Work.all

    respond_to do |format|
      format.xml { render :xml=>@works }
      format.json { render :json=>@works }
      format.html
    end
  end

  def lookup
# find an encoding that allows determining it's not really BSON ID
    respond_to do |format|
      #careful here not to allow injection of bad stuff in the regex
      format.json { render :json=>(Work.where(:title=>/#{params[:q]}/i).only(:title).limit(20).collect{|w| {id: w.id, name: w.title} } << {id: Base64::encode64(params[:q]).to_query("unlinked"), name: params[:q] + " (nouveau)"}) }
    end
  end

end
