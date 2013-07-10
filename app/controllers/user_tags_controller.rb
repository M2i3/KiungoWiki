class UserTagsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_taggable, except: :lookup
  authorize_resource :user_tag
  
  def update
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
        render json: (current_user.user_tags.where(name:/#{params[:q].to_s}/i).distinct(:name).collect{|tag| 
          {id:tag, name:tag}
        } << {id: params[:q].to_s, name: params[:q].to_s}).uniq
      end
    end
  end
  
  private
    def load_taggable
      resource, id = request.path.split('/')[1,2]
      singularized_resource = resource.singularize
      @taggable = singularized_resource.classify.constantize.find(id)
    end
end
