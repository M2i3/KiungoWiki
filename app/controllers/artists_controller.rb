class ArtistsController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, except: [:show, :index, :lookup, :portal, :recent_changes, :search, :alphabetic_index, :without_work, :without_recordings, :without_releases, :without_supplementary_sections, :report]
  authorize_resource
  skip_authorize_resource only: [:without_work, :without_recordings, :without_releases, :without_supplementary_sections, :report]
  before_filter :set_search_domain
  
  def index
    @artists = build_filter_from_params(params, Artist.all.order_by(cache_normalized_name:1))

    respond_to do |format|
      format.xml { render xml: @artists }
      format.json { render json: @artists }
      format.html {
         redirect_to(@artists.first) if (params[:autofollow] and @artists.size == 1 and @artists.first.signature == params[:signature])
      }
    end
  end
  
  def without_work
    @artists = Artist.where("typeof this.work_wiki_links == 'undefined' || this.work_wiki_links.length == 0").page(params[:page]).all
  end
  
  def without_recordings
    @artists = Artist.where("typeof this.recording_wiki_links == 'undefined' || this.recording_wiki_links.length == 0").page(params[:page]).all
  end
  
  def without_releases
    @artists = Artist.where("typeof this.release_wiki_link == 'undefined' || this.release_wiki_link.length == 0").page(params[:page]).all
  end
  
  def without_supplementary_sections
    @artists = Artist.where(missing_supplementary_sections: true).page(params[:page]).all
  end

  def recent_changes
    redirect_to changes_path(scope: "artist")
  end

  def portal
    @feature_in_month = PortalArticle.where(category: "artist", :publish_date.lte => Time.now).order_by(publish_date:-1).first
    respond_to do |format|
      format.html 
    end      
  end

  def alphabetic_index
    @artists = build_filter_from_params(params, Artist.where(cache_first_letter: params[:letter]).order_by(cache_normalized_name:1))
  end
  
  def show
    
    @artist = Artist.signed_as(params[:id]).first
    unless @artist
      @artist = Artist.find(params[:id])
      respond_to do |format|
        format.html { redirect_to( artist_path(id:@artist.to_search_query.url_encoded)) }
        format.xml  { render :xml => @artist, :location => artist_path(id: @artist.to_search_query.url_encoded, format:"xml") }
      end
    else
      if current_user
        @user_tags = @artist.user_tags.where(user: current_user).all
      end
      @json_src = artist_path(id:@artist.to_search_query.url_encoded, format:'json')
      respond_to do |format|
        format.xml { render xml: @artist.to_xml(except: [:versions]) }
        format.json { render json: @artist }
        format.html
      end
    end
  end

  def new
    unless params[:q]
      redirect_to search_artists_path, :alert=>t("messages.artist_new_without_query")
    else
      @artist = Artist.new(:surname=>params[:q])
      @supplementary_section = @artist.supplementary_sections.build
      respond_to do |format|      
        format.html # new.html.erb
        format.xml  { render :xml => @artist }
      end
    end
  end

  def create

    @artist = Artist.new(params[:artist])

    respond_to do |format|
      puts @artist.to_xml
      if @artist.save
        format.html { redirect_to(@artist , :notice => 'Artist succesfully created.') }
        format.xml  { render :xml => @artist, :status => :created, :location => @artist }

      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @artist.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def admin
    @artist = Artist.find(params[:id])
  end

  def edit
    @artist = Artist.find(params[:id])
  end
  
  def preview
    if params[:id]
      @artist = Artist.find(params[:id])
      @artist.assign_attributes params[:artist]
    else
      @artist = Artist.new params[:artist]
    end
    @artist.update_cached_fields
  end
  
  def add_supplementary_section
    @artist = Artist.find(params[:id])
    @artist.add_supplementary_section
    respond_to do |format|      
      format.html { render :action => "edit" }
      format.xml  { render :xml => @artist }
    end
  end 

  def update
    @artist = Artist.find(params[:id])
		
    respond_to do |format|
      if @artist.update_attributes(params[:artist])
        format.html { redirect_to(@artist, notice: "Artist succesfully updated.") }
        format.xml  { render :xml => @artist, status: :ok, location: @artist }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @artist = Artist.find(params[:id])
    
    @artist.destroy
    respond_to do |format|
      format.html { redirect_to(artists_url) }
      format.xml  { head :ok }
    end
  end

  def lookup

    wiki_link_klass = { "artist"=>ArtistArtistWikiLink, 
                        "recording"=>RecordingArtistWikiLink,
                        "work"=>WorkArtistWikiLink,
                        "release"=>ReleaseArtistWikiLink }[params[:src]] || ArtistWikiLink

    asq = wiki_link_klass.search_query(params[:q])


    respond_to do |format|
      format.json { 
        render json: (Artist.queried(asq.objectq).limit(20).collect{|art| 
          
          art.to_wiki_link(wiki_link_klass).combined_link

        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"})           
      }
    end


  end

  protected
    def filter_params
      {
        q: lambda {|artists, params| artists.queried(params[:q]) }
      }
    end

    def build_filter_from_params(params, artists)

      filter_params.each {|param_key, filter|
        puts "searching using #{param_key} with value #{params[param_key]}"
        artists = filter.call(artists,params) if params[param_key]
      }

      artists = artists.page(params[:page])

      artists
    end
    
    def set_search_domain
      @search_domain = "artists"
    end
end
