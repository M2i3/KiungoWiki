class UserTagsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_taggable
  before_filter :retrieve_tag, only: [:show, :edit, :update, :destroy]
  before_filter :build_tag, only: [:create, :new]
  authorize_resource :user_tag
  
  def index
    @user_tags = @taggable.user_tags.where(user_id:current_user)
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
        format.html { redirect_to @user_tag.taggable, notice: 'User tag was successfully updated.' }
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
        format.html { redirect_to @user_tag.taggable, notice: 'User tag was successfully created.' }
        format.json { render json: @user_tag, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @user_tag.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @user_tag.destroy
    respond_to do |format|
      format.html { redirect_to @user_tag.taggable }
      format.json { head :no_content }
    end
  end
  
  private
    def load_taggable
      resource, id = request.path.split('/')[1,2]
      singularized_resource = resource.singularize
      @taggable = singularized_resource.classify.constantize.find(id)
    end
    def retrieve_tag
      @user_tag = current_user.user_tags.where(taggable_type:@taggable.class.to_s, taggable_id:@taggable.id, id:params[:id]).first
    end
    def build_tag
      tag_params = {taggable_type:@taggable.class.to_s, taggable_id:@taggable.id}
      tag_params = tag_params.merge(params[:user_tag]) if params.has_key? :user_tag
      @user_tag = current_user.user_tags.build(tag_params)
    end
end
