class RecordingsController < ApplicationController

  def index
    @recordings = Recording.all
  end
  
  def show
    @recording = Recording.find(params[:id])
  end

  def new
    @recording = Recording.new
  end

  def create
    @recording = Recording.new(params[:recording])
    if @recording.save
      flash[:notice] = "Recording succesfully created"
      redirect_to @recording
    else
      render :action=>:new
    end
  end

  def edit 
    @recording = Recording.find(params[:id])
  end 

  def update
    @recording = Recording.find(params[:id])
    if @recording.version == params[:recording][:version].to_i
      if @recording.update_attributes(params[:recording])
        flash[:notice] = "Recording succesfully updated." 
        redirect_to @recording
      else
        render :action=>:edit
      end
    else
        flash[:error] = "The recording was updated by another user while you were editing it. You changes have been discarded."     
        redirect_to @recording
    end
  end
  
end
