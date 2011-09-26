class ArtistsController < ApplicationController

  def index
    @artists = Artist.all
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
# find an encoding that allows determining it's not really BSON ID
    respond_to do |format|
      #careful here not to allow injection of bad stuff in the regex
      format.json { render :json=>(Artist.where(:name=>/#{params[:q]}/i).only(:name).limit(20).collect{|w| {id: w.id.to_s.to_query("b"), name: w.name} } << {id: Base64::encode64(params[:q]).to_query("u"), name: params[:q] + " (nouveau)"}) }
    end
  end

end
