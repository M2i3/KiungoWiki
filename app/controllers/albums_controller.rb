class AlbumsController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :index, :lookup, :portal, :recent_changes, :search, :alphabetic_index]
  authorize_resource

  def index
    @albums = build_filter_from_params(params, Album.all.order_by(cache_normalized_title:1))

    respond_to do |format|
      format.xml { render :xml=>@albums }
      format.json { render :json=>@albums }
      format.html
    end
  end

  def recent_changes
    redirect_to changes_path(:scope=>"album")
  end

  def portal
    @feature_in_month = PortalArticle.where(:category =>"album", :publish_date.lte => Time.now).order_by(publish_date:-1).first
    respond_to do |format|
      format.html 
    end      
  end

  def alphabetic_index
    @albums = build_filter_from_params(params, Album.where(cache_first_letter: params[:letter]).order_by(cache_normalized_title:1))
  end
  
  def show
    @album = Album.find(params[:id])
    @possession = Possession.where(owner:current_user, album:@album).first if current_user
    respond_to do |format|
      format.xml { render :xml=>@album.to_xml(:except=>[:versions]) }
      format.json { render :json=>@album }
      format.html
    end
  end

  def new
    unless params[:q]
      redirect_to search_albums_path, :alert=>t("messages.album_new_without_query")
    else
      @album = Album.new(AlbumWikiLink.search_query(params[:q]).to_hash)
      @supplementary_section = @album.supplementary_sections.build
      respond_to do |format|      
        format.html # new.html.erb
        format.xml  { render :xml => @album }
      end
    end
  end

  def create

    @album = Album.new(params[:album])

    respond_to do |format|
      puts @album.to_xml
      if @album.save
        format.html { redirect_to(@album , :notice => 'Album succesfully created.') }
        format.xml  { render :xml => @album, :status => :created, :location => @album }

      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit 
    @album = Album.find(params[:id])
  end 

  def add_supplementary_section
    @album = Album.find(params[:id])
    @album.add_supplementary_section
    respond_to do |format|      
      format.html { render :action => "edit" }
      format.xml  { render :xml => @album }
    end
  end 

  def update
    @album = Album.find(params[:id])

    respond_to do |format|
      if @album.update_attributes(params[:album])
        format.html { redirect_to(@album, :notice => "Album succesfully updated.") }
        format.xml  { render :xml => @album, :status => :ok, :location => @album }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @album = Album.find(params[:id])
    
    @album.destroy
    respond_to do |format|
      format.html { redirect_to(albums_url) }
      format.xml  { head :ok }
    end
  end

  def lookup

    wiki_link_klass = { "artist"=>ArtistAlbumWikiLink,
                        "recording"=>RecordingAlbumWikiLink }[params[:src]] || AlbumWikiLink

    asq = wiki_link_klass.search_query(params[:q])
    data = (Album.queried(asq.objectq).limit(20).collect{|alb| 

          wiki_link_klass.new(reference_text: "oid:#{alb.id} #{asq.metaq}").combined_link
              
        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"}) 
    respond_to do |format|
      format.json { 
        render :json=>          data
      }
    end
  end

  protected
  def filter_params
    {
      :q => lambda {|albums, params| albums.queried(params[:q]) }
    }
  end

  def build_filter_from_params(params, albums)

    filter_params.each {|param_key, filter|
      puts "searching using #{param_key} with value #{params[param_key]}"
      albums = filter.call(albums,params) if params[param_key]
    }

    albums = albums.page(params[:page])

    albums
  end
end
