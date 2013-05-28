class UserTagsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def create
    respond_to do |format|
      if @user_tag.save
        format.json { render json: @user_tag, status: :created, location: @user_tag }
      else
        format.json { render json: @user_tag.errors, status: :unprocessable_entity }
      end
    end
  end
end
