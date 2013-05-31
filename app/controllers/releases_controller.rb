class ReleasesController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, except: [:show, :index, :lookup, :portal, :recent_changes, :search, :alphabetic_index]
  authorize_resource

  def index
    @releases = build_filter_from_params(params, Release.all.order_by(cache_normalized_title:1))
    
    respond_to do |format|
      format.xml { render xml: @releases }
      format.json { render json: @releases }
      format.html
    end
  end

  def recent_changes
    redirect_to changes_path(scope: "release")
  end

  def portal
    @feature_in_month = PortalArticle.where(category: "release", :publish_date.lte => Time.now).order_by(publish_date:-1).first
    respond_to do |format|
      format.html 
    end      
  end

  def alphabetic_index
    @releases = build_filter_from_params(params, Release.where(cache_first_letter: params[:letter]).order_by(cache_normalized_title:1))
  end
  
  def show
    @release = Release.find(params[:id])
    if current_user
      @possession = current_user.possessions.where("release_wiki_link.release_id" => @release.id).first
      @user_tags = current_user.user_tags.where(taggable_class: @release.class.to_s, taggable_id:@release.id).all
    end
    respond_to do |format|
      format.xml { render xml: @release.to_xml(except: [:versions]) }
      format.json { render json: @release }
      format.html
    end
  end

  def new
    unless params[:q]
      redirect_to search_releases_path, alert: t("messages.release_new_without_query")
    else
      @release = Release.new(ReleaseWikiLink.search_query(params[:q]).to_hash)
      @supplementary_section = @release.supplementary_sections.build
      respond_to do |format|      
        format.html # new.html.erb
        format.xml  { render xml: @release }
      end
    end
  end

  def create
    @release = Release.new(params[:release])
    respond_to do |format|
      if @release.save
        format.html { redirect_to(@release, notice: 'Release succesfully created.') }
        format.xml  { render xml: @release, status: :created, location: @release }
      else
        format.html { render action: :new }
        format.xml  { render xml: @release.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit 
    @release = Release.find(params[:id])
  end 

  def add_supplementary_section
    @release = Release.find(params[:id])
    @release.add_supplementary_section
    respond_to do |format|      
      format.html { render action: :edit }
      format.xml  { render xml: @release }
    end
  end 

  def update
    @release = Release.find(params[:id])

    respond_to do |format|
      if @release.update_attributes(params[:release])
        format.html { redirect_to(@release, notice: "Release succesfully updated.") }
        format.xml  { render xml: @release, status: :ok, location: @release }
      else
        format.html { render action: :edit }
        format.xml  { render xml: @release.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @release = Release.find(params[:id])
    
    @release.destroy
    respond_to do |format|
      format.html { redirect_to(releases_url) }
      format.xml  { head :ok }
    end
  end

  def lookup

    wiki_link_klass = { "artist"=>ArtistReleaseWikiLink,
                        "recording"=>RecordingReleaseWikiLink }[params[:src]] || ReleaseWikiLink

    asq = wiki_link_klass.search_query(params[:q])

    respond_to do |format|
      format.json { 
        render json:(Release.queried(asq.objectq).limit(20).collect{|alb| 

          wiki_link_klass.new(reference_text: "oid:#{alb.id} #{asq.metaq}").combined_link
              
        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"})           
      }
    end
  end

  protected
  def filter_params
    {
      q: lambda {|releases, params| releases.queried(params[:q]) }
    }
  end

  def build_filter_from_params(params, releases)

    filter_params.each {|param_key, filter|
      puts "searching using #{param_key} with value #{params[param_key]}"
      releases = filter.call(releases,params) if params[param_key]
    }

    releases = releases.page(params[:page])

    releases
  end
end
