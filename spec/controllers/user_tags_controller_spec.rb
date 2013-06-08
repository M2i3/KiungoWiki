require 'spec_helper'

describe UserTagsController do
  let(:user) { User.new }
  let(:tag) { UserTag.new }
  let(:tags) { Object.new }
  let(:id) { 99.to_param }
  let(:resource) { Artist.new }
  before :each do
    allow_message_expectations_on_nil
    ApplicationController.any_instance.stub(:current_user).and_return user
    request.env['warden'].stub(:authenticate!).and_return user
    UserTagsController.any_instance.stub(:authorize!)
    Artist.stub(:find).and_return resource
    resource.stub(:id).and_return 99
    user.should_receive(:user_tags).and_return user
    tag.stub(:id).and_return 99
    tag.stub(:taggable).and_return resource
  end
  describe "GET index" do
    before :each do
      @user_tags = [tag]
      user.should_receive(:where).with(taggable_type:"Artist", taggable_id:99).and_return @user_tags
    end
    it "assigns all user_tags as @user_tags" do
      @user_tags.should_not_receive(:where)
      get :index, artist_id:99.to_param
      assigns(:user_tags).should eq(@user_tags)
    end
  end
  describe "POST create" do
    before :each do
      user.should_receive(:build).with(taggable_type:"Artist", taggable_id:99).and_return tag
      @save_mock = tag.should_receive(:save)
    end
    it "can create with valid params" do
      @save_mock.and_return true
      post :create, user_tag: {}, format: :json, artist_id:99.to_param
      assigns(:user_tag).should be_a(UserTag)
      response.status.should eq(201)
    end
    it "cannot create with invalid params" do
      @save_mock.and_return(false)
      post :create, user_tag: {}, format: :json, artist_id:99.to_param
      response.status.should eq 422 
    end
  end
  describe "GET show" do
    before :each do
      user.should_receive(:where).with(taggable_type:"Artist", taggable_id:99, id:id).and_return user
      @find_mock = user.should_receive(:first)
    end
    it "assigns the requested possession as @possession" do
      @find_mock.and_return tag
      get :show, id: id, artist_id:99.to_param
      assigns(:user_tag).should eq(tag)
    end
  end

  describe "GET new" do
    it "assigns a new possession as @possession" do
      user.should_receive(:build).with(taggable_type:"Artist", taggable_id:99).and_return tag
      UserTagsController.any_instance.should_receive(:authorize!)
      get :new, artist_id:99.to_param
      assigns(:user_tag).should eq(tag)
    end
  end
  
  describe "GET edit" do
    it "assigns the requested possession as @possession" do
      user.should_receive(:where).with(taggable_type:"Artist", taggable_id:99, id:id).and_return user
      user.should_receive(:first).and_return tag
      get :edit, id: id, artist_id:99.to_param
      assigns(:user_tag).should eq(tag)
    end
  end
  
  describe "PUT update" do
    before :each do
      user.should_receive(:where).with(taggable_type:"Artist", taggable_id:99, id:id).and_return user
      user.should_receive(:first).and_return tag
    end
    it "with valid params can update" do
      params = { "these" => "params" }
      tag.should_receive(:update_attributes).with(params).and_return true
      put :update, id: id, user_tag: params, artist_id:99.to_param
      assigns(:user_tag).should eq(tag)
      response.status.should eq(302)
    end
    it "with invalid params cannot update" do
      params = { "these" => "params" }
      tag.should_receive(:update_attributes).with(params).and_return false
      put :update, id: id, user_tag: params, artist_id:99.to_param
      assigns(:user_tag).should eq(tag)
      response.should render_template("edit")
    end
  end
  
  describe "DELETE destroy" do
    it "destroys the requested possession" do
      user.should_receive(:where).with(taggable_type:"Artist", taggable_id:99, id:id).and_return user
      user.should_receive(:first).and_return tag
      tag.should_receive(:destroy)
      delete :destroy, id: id, artist_id:99.to_param
      response.should redirect_to(resource)
    end
  end
end
