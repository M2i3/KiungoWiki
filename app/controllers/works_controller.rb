class WorksController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, except: [:show, :index, :lookup, :portal, :recent_changes, :search, :alphabetic_index, :without_artist, :without_recordings, :without_lyrics, :without_tags, :without_supplementary_sections]
  authorize_resource
  skip_authorize_resource only: [:without_artist, :without_recordings, :without_lyrics, :without_tags, :without_supplementary_sections]

  def index
    @works = build_filter_from_params(params, Work.all.order_by(cache_normalized_title:1))

    respond_to do |format|
      format.xml { render xml: @works }
      format.json { render json: @works }
      format.html
    end
  end
  
  def without_artist
    @works = Work.where("artist_wiki_links.artist_id" => nil).page(params[:page]).all
  end
  
  def without_recordings
    @works = Work.where("recording_wiki_links.recording_id" => nil).page(params[:page]).all
  end
  
  def without_lyrics
    @works = Work.where(:lyrics.in => [nil,""]).page(params[:page]).all
  end

  def without_tags
    @works = Work.where(missing_tags: true).page(params[:page]).all
  end
  
  def without_supplementary_sections
    @works = Work.where(missing_supplementary_sections: true).page(params[:page]).all
  end

  def recent_changes
    redirect_to changes_path(scope: "work")
  end

  def portal
    @feature_in_month = PortalArticle.where(category: "work", :publish_date.lte => Time.now).order_by(publish_date:-1).first
    respond_to do |format|
      format.html 
    end      
  end

  def alphabetic_index
    @works = build_filter_from_params(params, Work.where(cache_first_letter: params[:letter]).order_by(cache_normalized_name:1))
  end

  def show
    @work = Work.find(params[:id])
    if current_user
      @user_tags = @work.user_tags.where(user:current_user).all
    end
    respond_to do |format|
      format.xml { render xml: @work.to_xml(except: [:versions]) }
      format.json { render json: @work }
      format.html
    end
  end

  def new
    unless params[:q]
      redirect_to search_works_path, alert: t("messages.work_new_without_query")
    else
      @work = Work.new(WorkWikiLink.search_query(params[:q]).to_hash)
      @supplementary_section = @work.supplementary_sections.build
      respond_to do |format|      
        format.html # new.html.erb
        format.xml  { render :xml => @work }
      end
    end
  end

  def create

    @work = Work.new(params[:work])

    respond_to do |format|
      puts @work.to_xml
      if @work.save
        format.html { redirect_to(@work , :notice => 'Work succesfully created.') }
        format.xml  { render :xml => @work, :status => :created, :location => @work }

      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit 
    @work = Work.find(params[:id])
  end 

  def add_supplementary_section
    @work = Work.find(params[:id])
    @work.add_supplementary_section
    respond_to do |format|      
      format.html { render :action => "edit" }
      format.xml  { render :xml => @work }
    end
  end 

  def update
    @work = Work.find(params[:id])

    respond_to do |format|
      if @work.update_attributes(params[:work])
        format.html { redirect_to(@work, :notice => "Work succesfully updated.") }
        format.xml  { render :xml => @work, :status => :ok, :location => @work }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @work = Work.find(params[:id])
    
    @work.destroy
    respond_to do |format|
      format.html { redirect_to(works_url) }
      format.xml  { head :ok }
    end
  end

  def lookup

    wiki_link_klass = { "artist"=>ArtistWorkWikiLink, 
                        "recording"=>RecordingWorkWikiLink,
                        "work"=>WorkWorkWikiLink }[params[:src]] || WorkWikiLink

    wsq = wiki_link_klass.search_query(params[:q])

    respond_to do |format|
      format.json { 
        render :json=>(Work.queried(wsq.objectq).limit(20).collect{|w|
          
          wiki_link_klass.new(reference_text: "oid:#{w.id} #{wsq.metaq}").combined_link

        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"})           
      }
    end
  end

  protected
  def filter_params
    {
      :q => lambda {|works, params| works.queried(params[:q]) }
    }
  end

  def build_filter_from_params(params, works)

    filter_params.each {|param_key, filter|
      puts "searching using #{param_key} with value #{params[param_key]}"
      works = filter.call(works,params) if params[param_key]
    }

    works = works.page(params[:page])

    works
  end
end
