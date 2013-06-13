class UserTagsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_taggable, except: :lookup
  before_filter :retrieve_tag, only: [:show, :edit, :update, :destroy]
  before_filter :build_tag, only: [:new]
  authorize_resource :user_tag
  
  def index
    @user_tags = @taggable.user_tags.where(default_params)
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
    @taggable.user_tags_text[current_user] = params[:user_tag][:name]
    respond_to do |format|
      format.html { redirect_to @user_tag.taggable, notice: 'User tag was successfully created.' }
      format.json { render json: @user_tag, status: :created }
    end
  end
  
  def lookup
    respond_to do |format|
      format.json do
        # 
        render json: (current_user.user_tags.where(name:/#{params[:q].to_s}/i).collect{|tag| 
          {id:tag.name, name:tag.name}
        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"})           
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
    def default_params
      {user_id:current_user}
    end
    def retrieve_tag
      @user_tag = @taggable.user_tags.where(default_params).first
    end
    def build_tag
      tag_params = default_params
      tag_params = tag_params.merge(params[:user_tag]) if params.has_key? :user_tag
      @user_tag = @taggable.user_tags.build(tag_params)
    end
end
