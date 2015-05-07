class Admin::UsersController < ApplicationController
  load_and_authorize_resource
  
  def index
    @users = User.page(params[:page]).all
  end
  
  def show
    
  end
  
  def edit
    
  end
  
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(admin_user_path(@user), notice: "User succesfully updated.") }
        format.xml  { render xml: @user, status: :ok, location: @user }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end
  
  def lookup_groups
    respond_to do |format|
      format.json do
        # 
        case params[:q].to_s
        when "?", "*"
          query = ".*"
        else
          query = Regexp.escape(params[:q].to_s)
        end
        
        render json: (User.groups.select {|g| /#{query}/.match(g) }.collect{|g| {id:g, name:g} }).uniq
      end
    end
  end
  
end
