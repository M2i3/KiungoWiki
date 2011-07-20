class RecordingsController < ApplicationController

  def index
    @recordings = Recording.all
  end
  
  def show
    @recording = Recording.find(params[:id])  
    respond_to do |format|
      format.xml { render :xml=>@recording.to_xml(:except=>[:versions]) }
      format.json { render :json=>@recording }
      format.html
    end

  end

  def new
    @recording = Recording.new
    respond_to do |format|      
      format.html # new.html.erb
      format.xml  { render :xml => @recording }
    end
  end

  def create
    @recording = Recording.new(params[:recording])

    respond_to do |format|
      puts @recording.to_xml
      if @recording.save
        format.html { redirect_to(@recording , :notice => 'Recording succesfully created.') }
        format.xml  { render :xml => @recording, :status => :created, :location => @recording }

      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recording.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit 
    @recording = Recording.find(params[:id])
  end 

  def update
    @recording = Recording.find(params[:id])

    respond_to do |format|
      if @recording.version == params[:recording][:version].to_i
        if @recording.update_attributes(params[:recording])
          format.html { redirect_to(@recording, :notice => "Recording succesfully updated.") }
          format.xml  { render :xml => @recording, :status => :ok, :location => @recording }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @recording.errors, :status => :unprocessable_entity }
        end
      else
        format.html { redirect_to(@recording, :error => "The recording was updated by another user while you were editing it. You changes have been discarded.") }
        format.xml  { render :xml => {:version=>"Invalid Version Number"}, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @recording = Recording.find(params[:id])
    
    @recording.destroy
    respond_to do |format|
      format.html { redirect_to(recordings_url) }
      format.xml  { head :ok }
    end
  end

end
