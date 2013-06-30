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
      recording.should_receive(:user_tags).and_return UserTag
      UserTag.should_receive(:where).with(user:user).and_return UserTag
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
  context "GET without sections" do
    before :each do
      @recordings = []
      @page = "98"
      Recording.should_receive(:page).with(@page).and_return Recording
      @where_mock = Recording.should_receive(:where)
      Recording.should_receive(:all).and_return @recordings
    end
    after :each do 
      assigns(:recordings).should eq @recordings
    end
    describe "GET without_arist" do
      it "should handle pagination and show works without artists" do
        @where_mock.with("artist_wiki_links.artist_id" => nil).and_return Recording
        get :without_artist, page:@page
      end
    end
    describe "GET without_releases" do
      it "should handle pagination and show works without lyrics" do
        @where_mock.with("release_wiki_link.release_id" => nil).and_return Recording
        get :without_releases, page:@page
      end
    end
    describe "GET without_tags" do
      it "should handle pagination and show works without tags" do
        @where_mock.with(missing_tags: true).and_return Recording
        get :without_tags, page:@page
      end
    end
    describe "GET without_additonal_sections" do
      it "should handle pagination and show works without additional_sections" do
        @where_mock.with(missing_supplementary_sections: true).and_return Recording
        get :without_supplementary_sections, page:@page
      end
    end
  end
end
