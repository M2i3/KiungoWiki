require 'spec_helper'

describe ArtistsController do
  let(:artist) { Artist.new }
  let(:user) { User.new }
  let(:id) { 99.to_param }
  before :each do
    ArtistsController.any_instance.stub(:authorize!)
  end
  describe "GET show" do
    before :each do
      Artist.should_receive(:find).with(id).and_return artist
    end
    it "should show an artist upon request and list the users tags if there is any" do
      ApplicationController.any_instance.stub(:current_user).and_return user
      request.env['warden'].stub(:authenticate!).and_return user
      artist.should_receive(:user_tags).and_return UserTag
      UserTag.should_receive(:where).with(user:user).and_return UserTag
      tags = []
      UserTag.should_receive(:all).and_return tags
      get :show, id: id
      assigns(:artist).should eq artist
      assigns(:user_tags).should eq tags
    end
    it "should not pull the user tags if no user is logged in" do
      user.should_not_receive(:user_tags)
      get :show, id: id
      assigns(:artist).should eq artist
      assigns(:user_tags).should eq nil
    end
  end
  context "GET without sections" do
    before :each do
      @artists = []
      @page = "98"
      Artist.should_receive(:page).with(@page).and_return Artist
      @where_mock = Artist.should_receive(:where)
      Artist.should_receive(:all).and_return @artists
    end
    after :each do 
      assigns(:artists).should eq @artists
    end
    describe "GET without_work" do
      it "should handle pagination and show works without works" do
        @where_mock.with("typeof this.work_wiki_links == 'undefined' || this.work_wiki_links.length == 0").and_return Artist
        get :without_work, page:@page
      end
    end
    describe "GET without_recordings" do
      it "should handle pagination and show works without recordings" do
        @where_mock.with("typeof this.recording_wiki_links == 'undefined' || this.recording_wiki_links.length == 0").and_return Artist
        get :without_recordings, page:@page
      end
    end
    describe "GET without_releases" do
      it "should handle pagination and show works without releases" do
        @where_mock.with("typeof this.release_wiki_link == 'undefined' || this.release_wiki_link.length == 0").and_return Artist
        get :without_releases, page:@page
      end
    end
    describe "GET without_additonal_sections" do
      it "should handle pagination and show works without additional_sections" do
        @where_mock.with(missing_supplementary_sections: true).and_return Artist
        get :without_supplementary_sections, page:@page
      end
    end
  end
end
