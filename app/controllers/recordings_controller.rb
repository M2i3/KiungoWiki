class RecordingsController < ApplicationController
  
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
    if @recording.update_attributes(params[:recording])
      flash[:notice] = "Recording succesfully updated"
      redirect_to @recording
    else
      render :action=>:edit
    end
  end
  
end
