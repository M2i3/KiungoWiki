require 'spec_helper'

describe WorksController do
  let(:work) { Work.new }
  let(:user) { User.new }
  let(:id) { 99.to_param }
  before :each do
    WorksController.any_instance.stub(:authorize!)
  end
  describe "GET show" do
    before :each do
      Work.should_receive(:find).with(id).and_return work
    end
    it "should show an work upon request and list the users tags if there is any" do
      ApplicationController.any_instance.stub(:current_user).and_return user
      request.env['warden'].stub(:authenticate!).and_return user
      work.should_receive(:user_tags).and_return UserTag
      UserTag.should_receive(:where).with(user:user).and_return UserTag
      UserTag.should_receive(:all).and_return nil
      get :show, id: id
      assigns(:work).should eq work
      assigns(:user_tags).should eq nil
    end
    it "should not pull the user tags if no user is logged in" do
      user.should_not_receive(:user_tags)
      get :show, id: id
      assigns(:work).should eq work
      assigns(:user_tags).should eq nil
    end
  end
  context "GET without sections" do
    before :each do
      @works = []
      @page = "98"
      Work.should_receive(:page).with(@page).and_return Work
      Work.should_receive(:all).and_return @works
    end
    after :each do 
      # assigns(:works).should eq @works
    end
    describe "GET without_artists" do
      it "should handle pagination and show works without artists" do
        Work.should_receive(:where).with("artist_wiki_links.artist_id" => nil).and_return Work
        get :without_artist, page:@page
      end
    end
    describe "GET without_recordings" do
      it "should handle pagination and show works without recordings" do
        Work.should_receive(:where).with("recording_wiki_links.recording_id" => nil).and_return Work
        get :without_recordings, page:@page
      end
    end
    describe "GET without_lyrics" do
      it "should handle pagination and show works without lyrics" do
        Work.should_receive(:where).with(:lyrics.in => [nil,""]).and_return Work
        get :without_lyrics, page:@page
      end
    end
    describe "GET without_tags" do
      # it "should handle pagination and show works without tags" do
      #   Work.should_receive(:where).with("public_tags" => nil).and_return Work
      #   get :without_artist, page:@page
      # end
    end
    describe "GET without_additonal_sections" do
      # it "should handle pagination and show works without additional_sections" do
      #   Work.should_receive(:where).with("artist_wiki_links.artist_id" => nil).and_return Work
      #   get :without_artist, page:@page
      # end
    end
  end
end
