class WorksController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :index, :lookup, :portal, :recent_changes, :search, :alphabetic_index]
  authorize_resource

  def index
    @works = build_filter_from_params(params, Work.all.order(cache_normalized_title:1))

    respond_to do |format|
      format.xml { render :xml=>@works }
      format.json { render :json=>@works }
      format.html
    end
  end

  def recent_changes
    redirect_to changes_path(:scope=>"work")
  end

  def portal
    @feature_in_month = PortalArticle.where(:category =>"work", :publish_date.lte => Time.now).order(publish_date:-1).first
    respond_to do |format|
      format.html 
    end      
  end

  def alphabetic_index
    @works = build_filter_from_params(params, Work.where(cache_first_letter: params[:letter]).order(cache_normalized_title:1))
  end

  def show
    @work = Work.find(params[:id])

    respond_to do |format|
      format.xml { render :xml=>@work.to_xml(:except=>[:versions]) }
      format.json { render :json=>@work }
      format.html
    end
  end

  def new
    unless params[:q]
      redirect_to search_works_path, :alert=>t("messages.work_new_without_query")
    else
      @work = Work.new(WorkSearchQuery.new(params[:q]).to_hash)
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
