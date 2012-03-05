class RecordingsController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :index, :lookup]

  def index
    @recordings = Recording.all(sort: [:title, :asc]) #TODO: Add an index on title to enable sorting on huge number of recordings
    @recordings = @recordings.queried(params[:q]) if params[:q]

    @recordings = @recordings.page(params[:page])

    respond_to do |format|
      format.xml { render :xml=>@recordings }
      format.json { render :json=>@recordings }
      format.html
    end
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
      if @recording.update_attributes(params[:recording])
        format.html { redirect_to(@recording, :notice => "Recording succesfully updated.") }
        format.xml  { render :xml => @recording, :status => :ok, :location => @recording }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recording.errors, :status => :unprocessable_entity }
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

  def lookup
    rsq = RecordingSearchQuery.new(params[:q])
    respond_to do |format|
      format.json { 
        render :json=>(Recording.queried(params[:q]).limit(20).collect{|r| 
          reference_text = ["oid:#{r.id}"]
          reference_label = [r.title]
          if rsq[:trackNb]
            reference_text << "trackNb:#{rsq[:trackNb]}"
            reference_label << "(#{rsq[:trackNb]})"
          end
          if rsq[:itemId]
            reference_text << "itemId:#{rsq[:itemId]}"
            reference_label << "(#{rsq[:itemId]})"
          end
          if rsq[:itemSection]
            reference_text << "itemSection:#{rsq[:itemSection]}"
            reference_label << "(#{rsq[:itemSection]})"
          end
          {id: reference_text.join(" "), name: reference_label.join(" ")} 
        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"}) 
      }
    end
  end
end
