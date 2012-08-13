class ArtistsController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :index, :lookup]
  authorize_resource

  def index
    @artists = Artist.all(sort: [:name, :asc]) #TODO: Add an index on title to enable sorting on huge number of artists
    @artists = @artists.queried(params[:q]) if params[:q]

    @artists = @artists.page(params[:page])

    respond_to do |format|
      format.xml { render :xml=>@artists }
      format.json { render :json=>@artists }
      format.html
    end
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
    @artist = Artist.new
    respond_to do |format|      
      format.html # new.html.erb
      format.xml  { render :xml => @artist }
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
  	logger.info "PARAMS[:artist]"
  	logger.info params[:artist]
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

    asq = ArtistSearchQuery.new(params[:q])

    respond_to do |format|
      format.json { 
        render :json=>(Artist.queried(params[:q]).limit(20).collect{|w| 

          ArtistWikiLink.new(reference_text: "oid:#{w.id} #{asq.metaq}").combined_link

        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"})           
      }
    end
  end
end
