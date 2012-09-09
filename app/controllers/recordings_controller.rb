class RecordingsController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :index, :lookup, :portal, :recent_changes, :search, :alphabetic_index]

  def index
    @recordings = build_filter_from_params(params, Recording.all.order(cache_normalized_title:1))

    respond_to do |format|
      format.xml { render :xml=>@recordings }
      format.json { render :json=>@recordings }
      format.html
    end
  end
  
  def recent_changes
    @recordings = build_filter_from_params(params, Recording.all.order(updated_at:-1))
  end

  def portal
    @feature_in_month = PortalArticle.where(:category =>"recording", :publish_date.lte => Time.now).order(publish_date:-1).first
    respond_to do |format|
      format.html 
    end      
  end

  def alphabetic_index
    @recordings = build_filter_from_params(params, Recording.where(cache_first_letter: params[:letter]).order(cache_normalized_title:1))
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
    unless params[:q]
      redirect_to search_recordings_path, :alert=>t("messages.recording_new_without_query")
    else
      @recording = Recording.new(RecordingSearchQuery.new(params[:q]).to_hash)
      respond_to do |format|      
        format.html # new.html.erb
        format.xml  { render :xml => @recording }
      end
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
          if ![nil,"","0"].include?(r.duration.to_s)
            if ![nil,"","0"].include?(r.recording_date)
              if ![nil,""].include?(r.artist_wiki_links.first)
                reference_label = [r.title + " (" + r.duration.to_s + ", " + r.recording_date + ") - " + r.artist_wiki_links.first.name(true)]
              else
                reference_label = [r.title + " (" + r.duration.to_s + ", " + r.recording_date + ")"] 
              end
            else
              if ![nil,""].include?(r.artist_wiki_links.first)
                reference_label = [r.title + " (" + r.duration.to_s + ") - " + r.artist_wiki_links.first.name(true)]
              else
                reference_label = [r.title + " (" + r.duration.to_s + ")"] 
              end
            end
          else
            if ![nil,""].include?(r.recording_date)
              if ![nil,""].include?(r.artist_wiki_links.first)
                reference_label = [r.title + " (" + r.recording_date + ") - " + r.artist_wiki_links.first.name(true)]
              else
                reference_label = [r.title + " (" + r.recording_date + ")"] 
              end
            else
              reference_label = [r.title] 
            end
          end

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

  protected
  def filter_params
    {
      :q => lambda {|recordings, params| recordings.queried(params[:q]) }
    }
  end

  def build_filter_from_params(params, recordings)

    filter_params.each {|param_key, filter|
      puts "searching using #{param_key} with value #{params[param_key]}"
      recordings = filter.call(recordings,params) if params[param_key]
    }

    recordings = recordings.page(params[:page])

    recordings
  end
end
