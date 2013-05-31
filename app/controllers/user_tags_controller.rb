class UserTagsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def index
    
  end
  
  def show
    respond_to do |format|
      format.html
      format.json { render json: @user_tag }
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |format|
      if @user_tag.update_attributes(params[:user_tag])
        format.html { redirect_to @user_tag, notice: 'User tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_tag.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def new
    respond_to do |format|
      format.html
      format.json { render json: @user_tag }
    end
  end
  
  def create
    respond_to do |format|
      if @user_tag.save
        format.html { redirect_to @user_tag, notice: 'User tag was successfully created.' }
        format.json { render json: @user_tag, status: :created, location: @user_tag }
      else
        format.html { render action: "new" }
        format.json { render json: @user_tag.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @user_tag.destroy
    respond_to do |format|
      format.html { redirect_to user_tags_url }
      format.json { head :no_content }
    end
  end
end
