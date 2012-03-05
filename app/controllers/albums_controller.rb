class AlbumsController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :index, :lookup]


  def index
    @albums = Album.all(sort: [:title, :asc]) # TODO: Add an index on title to enable sorting on huge number of albums
    @albums = @albums.queried(params[:q]) if params[:q]

    @albums = @albums.page(params[:page])

    respond_to do |format|
      format.xml { render :xml=>@albums }
      format.json { render :json=>@albums }
      format.html
    end
  end

  def show
    @album = Album.find(params[:id])

    respond_to do |format|
      format.xml { render :xml=>@recording.to_xml(:except=>[:versions]) }
      format.json { render :json=>@album }
      format.html
    end
  end

  def new

    @album = Album.new
    respond_to do |format|      
      format.html # new.html.erb
      format.xml  { render :xml => @album }
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
# find an encoding that allows determining it's not really BSON ID
    respond_to do |format|
      #careful here not to allow injection of bad stuff in the regex
      format.json { 
        render :json=>(Album.queried(params[:q]).limit(20).collect{|w| 
          reference_text = ["oid:#{w.id}"]
          reference_label = [w.title]
          {id: reference_text.join(" "), name: reference_label.join(" ")}               
        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"})           
      }
    end
  end
end
