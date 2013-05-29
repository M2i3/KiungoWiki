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
end
