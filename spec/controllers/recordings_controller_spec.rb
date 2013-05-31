require 'spec_helper'

describe RecordingsController do
  let(:recording) { Recording.new }
  let(:user) { User.new }
  let(:id) { 99.to_param }
  before :each do
    RecordingsController.any_instance.stub(:authorize!)
  end
  describe "GET show" do
    before :each do
      Recording.should_receive(:find).with(id).and_return recording
    end
    it "should show an recording upon request and list the users tags if there is any" do
      ApplicationController.any_instance.stub(:current_user).and_return user
      request.env['warden'].stub(:authenticate!).and_return user
      recording.should_receive(:id).and_return id
      user.should_receive(:user_tags).and_return UserTag
      UserTag.should_receive(:where).with(taggable_id: id, taggable_class: recording.class.to_s).and_return UserTag
      tags = []
      UserTag.should_receive(:all).and_return tags
      get :show, id: id
      assigns(:recording).should eq recording
      assigns(:user_tags).should eq tags
    end
    it "should not pull the user tags if no user is logged in" do
      user.should_not_receive(:user_tags)
      get :show, id: id
      assigns(:recording).should eq recording
      assigns(:user_tags).should eq nil
    end
  end
end
