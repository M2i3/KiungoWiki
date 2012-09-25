class ArtistsController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :index, :lookup, :portal, :recent_changes, :search, :alphabetic_index]
  authorize_resource

  def index
    @artists = build_filter_from_params(params, Artist.all.order(cache_normalized_name:1))

    respond_to do |format|
      format.xml { render :xml=>@artists }
      format.json { render :json=>@artists }
      format.html
    end
  end

  def recent_changes
    redirect_to changes_path(:scope=>"artist")
  end

  def portal
    @feature_in_month = PortalArticle.where(:category =>"artist", :publish_date.lte => Time.now).order(publish_date:-1).first
    respond_to do |format|
      format.html 
    end      
  end

  def alphabetic_index
    @artists = build_filter_from_params(params, Artist.where(cache_first_letter: params[:letter]).order(cache_normalized_name:1))
  end
  
  def show
    @artist = Artist.find(params[:id])
    respond_to do |format|
      format.xml { render :xml=>@artist.to_xml(:except=>[:versions]) }
      format.json { render :json=>@artist }
      format.html
    end
  end

  def new
    unless params[:q]
      redirect_to search_artists_path, :alert=>t("messages.artist_new_without_query")
    else
      @artist = Artist.new(ArtistSearchQuery.new(params[:q]).to_hash)
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

  def edit
    @artist = Artist.find(params[:id])
  end 

  def update
    @artist = Artist.find(params[:id])
		
    respond_to do |format|
      if @artist.update_attributes(params[:artist])
        format.html { redirect_to(@artist, :notice => "Artist succesfully updated.") }
        format.xml  { render :xml => @artist, :status => :ok, :location => @artist }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @artist.errors, :status => :unprocessable_entity }
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
                        "album"=>AlbumArtistWikiLink }[params[:src]] || ArtistWikiLink

    asq = wiki_link_klass.search_query(params[:q])


    respond_to do |format|
      format.json { 
        render :json=>(Artist.queried(asq.objectq).limit(20).collect{|art| 

          wiki_link_klass.new(reference_text: "oid:#{art.id} #{asq.metaq}").combined_link

        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"})           
      }
    end


  end

  protected
  def filter_params
    {
      :q => lambda {|artists, params| artists.queried(params[:q]) }
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
end
