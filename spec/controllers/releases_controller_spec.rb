require 'spec_helper'

describe ReleasesController do
  let(:user) { User.new }
  before :each do
    allow_message_expectations_on_nil
    ApplicationController.any_instance.stub(:current_user).and_return user
    request.env['warden'].stub(:authenticate!).and_return user
  end
  describe "GET index" do
    it "should filter on the index" do
      releases = Object.new
      Release.should_receive(:all).and_return Release
      Release.should_receive(:order_by).with(cache_normalized_title:1).and_return releases
      ReleasesController.any_instance.should_receive(:build_filter_from_params).and_return releases
      get :index
      assigns(:releases).should eq releases
    end
  end
  describe "GET show" do
    it "should show a release upon request" do
      id = 99.to_param
      release = Object.new
      Release.should_receive(:find).with(id).and_return release
      Possession.should_receive(:where).with(owner:user, release:release).and_return Possession
      Possession.should_receive(:first).and_return nil
      get :show, id: id
      assigns(:release).should eq release
      assigns(:possession).should eq nil
    end
  end
  describe "GET portal" do
    it "should pull the proper PortalArticle" do
      article = Object.new
      Time.should_receive(:now).at_least(1).and_return article
      article.should_receive(:-).at_least(1).and_return 1
      PortalArticle.should_receive(:where).with(category:"release", :publish_date.lte => article).and_return article
      article.should_receive(:order_by).with(publish_date:-1).and_return article
      article.should_receive(:first).and_return article
      get :portal
      assigns(:feature_in_month).should eq article
    end
  end
  describe "GET lookup" do
    it "should be able to lookup releases" do
      {ReleaseWikiLink => nil, ArtistAlbumWikiLink => "artist", 
      RecordingAlbumWikiLink => "recording"}.each do |link, src_param|
        q = "test"
        data = Object.new
        link.should_receive(:search_query).with(q).and_return data
        Release.should_receive(:queried).with(data).and_return data
        data.should_receive(:objectq).and_return data
        data.should_receive(:limit).with(20).and_return [data]
        data.should_receive(:id).and_return 1
        data.should_receive(:metaq).and_return 2
        wiki_link = Object.new
        link.should_receive(:new).with(reference_text:"oid:#{1} #{2}").and_return wiki_link
        wiki_link.should_receive(:combined_link)
        get :lookup, q:q, format: :json, src:src_param
      end
    end
  end
  describe "GET recent_changes" do
    it "should redirect to changes_path with scope of release" do
      get :recent_changes
      response.should redirect_to changes_path scope: "release"
    end
  end
  describe "GET alphabetic_index" do
    it "should work" do
      letter = "a"
      releases = Object.new
      Release.should_receive(:where).with(cache_first_letter:letter).and_return releases
      releases.should_receive(:order_by).with(cache_normalized_title:1).and_return releases
      ReleasesController.any_instance.should_receive(:build_filter_from_params).with(an_instance_of(ActiveSupport::HashWithIndifferentAccess), releases).and_return releases
      get :alphabetic_index, letter:letter
      assigns(:albums).should eq releases
    end
  end
end
