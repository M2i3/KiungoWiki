require 'spec_helper'

describe UserTagsController do
  let(:user) { User.new }
  let(:tag) { UserTag.new }
  let(:tags) { Object.new }
  let(:id) { 99.to_param }
  before :each do
    allow_message_expectations_on_nil
    ApplicationController.any_instance.stub(:current_user).and_return user
    request.env['warden'].stub(:authenticate!).and_return user
    UserTagsController.any_instance.stub(:authorize!)
  end
  describe "GET index" do
    before :each do
      @user_tags = [tag]
      UserTag.should_receive(:accessible_by).and_return @user_tags
    end
    it "assigns all user_tags as @user_tags" do
      @user_tags.should_not_receive(:where)
      get :index, {}
      assigns(:user_tags).should eq(@user_tags)
    end
  end
  describe "POST create" do
    before :each do
      tag.should_receive(:user=).with user
      UserTag.should_receive(:new).and_return tag
      @save_mock = tag.should_receive(:save)
    end
    it "can create with valid params" do
      @save_mock.and_return true
      post :create, user_tag: {}, format: :json
      assigns(:user_tag).should be_a(UserTag)
      response.status.should eq(201)
    end
    it "cannot create with invalid params" do
      @save_mock.and_return(false)
      post :create, user_tag: {}, format: :json
      response.status.should eq 422 
    end
  end
  describe "GET show" do
    before :each do
      @find_mock = UserTag.should_receive(:find).with(id)
    end
    it "assigns the requested possession as @possession" do
      @find_mock.and_return tag
      get :show, {id: id}
      assigns(:user_tag).should eq(tag)
    end
  end

  describe "GET new" do
    it "assigns a new possession as @possession" do
      UserTagsController.any_instance.should_receive(:authorize!)
      tag.should_receive(:user=).with user
      UserTag.should_receive(:new).and_return tag
      get :new, {}
      assigns(:user_tag).should eq(tag)
    end
  end
  
  describe "GET edit" do
    it "assigns the requested possession as @possession" do
      UserTag.should_receive(:find).with(id).and_return tag
      get :edit, {id: id}
      assigns(:user_tag).should eq(tag)
    end
  end
  
  describe "PUT update" do
    before :each do
      UserTag.should_receive(:find).with(id).and_return tag
    end
    it "with valid params can update" do
      params = { "these" => "params" }
      tag.should_receive(:update_attributes).with(params).and_return true
      put :update, {id: id, user_tag: params}
      assigns(:user_tag).should eq(tag)
      response.status.should eq(302)
    end
    it "with invalid params cannot update" do
      params = { "these" => "params" }
      tag.should_receive(:update_attributes).with(params).and_return false
      put :update, {id: id, user_tag: params}
      assigns(:user_tag).should eq(tag)
      response.should render_template("edit")
    end
  end
  
  describe "DELETE destroy" do
    it "destroys the requested possession" do
      UserTag.should_receive(:find).with(id).and_return tag
      tag.should_receive(:destroy)
      delete :destroy, {id: id}
      response.should redirect_to(user_tags_url)
    end
  end
end
