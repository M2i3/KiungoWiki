require 'spec_helper'

describe ReleasesController do
  let(:user) { User.new }
  let(:release) { Object.new }
  let(:id) { 99.to_param }
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
    it "should show a release upon request along with their user tags if they are logged in" do
      Release.should_receive(:find).with(id).and_return release
      release.should_receive(:id).at_least(1).and_return id
      user.should_receive(:possessions).and_return Possession
      Possession.should_receive(:where).with("release_wiki_link.release_id" => id).and_return Possession
      Possession.should_receive(:first).and_return nil
      user.should_receive(:user_tags).and_return UserTag
      UserTag.should_receive(:where).with(taggable_id: id, taggable_class: release.class.to_s).and_return UserTag
      tags = []
      UserTag.should_receive(:all).and_return tags
      get :show, id: id
      assigns(:release).should eq release
      assigns(:possession).should eq nil
      assigns(:user_tags).should eq tags
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
      {ReleaseWikiLink => nil, ArtistReleaseWikiLink => "artist", 
      RecordingReleaseWikiLink => "recording"}.each do |link, src_param|
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
      assigns(:releases).should eq releases
    end
  end
  describe "GET new" do
    it "should redirect to search_releases_path if no q parameter" do
      get :new
      response.should redirect_to search_releases_path
      flash[:alert].should eq I18n.t("messages.release_new_without_query")
    end
    it "should let you initiate a new release if you have the q param filled" do
      section = Object.new
      q = "test"
      link = {}
      ReleaseWikiLink.should_receive(:search_query).with(q).and_return link
      Release.should_receive(:new).with(link).and_return release
      release.should_receive(:supplementary_sections).and_return release
      release.should_receive(:build).and_return section
      get :new, q:q
      assigns(:release).should eq release
      assigns(:supplementary_section).should eq section
    end
  end
  describe "POST create" do
    before :each do
      @release_params = HashWithIndifferentAccess.new {name:"Test"}
      @release = Release.new(id: 99)
      Release.should_receive(:new).with(@release_params).and_return @release
      @release_save = @release.should_receive(:save)
    end
    it "should redirect to the new release after creation" do
      @release_save.and_return true
      post :create, release:@release_params
      response.should redirect_to @release
      flash[:notice].should eq 'Release succesfully created.'
    end
    it "should render new if failed to create" do
      @release_save.and_return false
      post :create, release:@release_params
      response.should render_template :new
      assigns(:release).should eq @release
    end
  end
  describe "GET edit" do
    it "should render properly a release to be edited" do
      id = "99"
      Release.should_receive(:find).with(id).and_return release
      get :edit, id:id
      response.should render_template :edit
      assigns(:release).should eq release
    end
  end
  describe "GET add_supplementary_section" do
    it "should be able to add supplementary section" do
      id = "99"
      Release.should_receive(:find).with(id).and_return release
      release.should_receive(:add_supplementary_section)
      get :add_supplementary_section, id:id
      assigns(:release).should eq release
      response.should render_template :edit
    end
  end
  describe "PUT update" do
    before :each do
      @release_params = HashWithIndifferentAccess.new {name:"Test"}
      @release = Release.new(id: 99)
      @id = @release.id.to_s
      Release.should_receive(:find).with(@id).and_return @release
      @release_update = @release.should_receive(:update_attributes)
    end
    it "should redirect to the new release after creation" do
      @release_update.and_return true
      put :update, release:@release_params, id:@id
      response.should redirect_to @release
      flash[:notice].should eq 'Release succesfully updated.'
    end
    it "should render new if failed to create" do
      @release_update.and_return false
      put :update, release:@release_params, id:@id
      response.should render_template :edit
      assigns(:release).should eq @release
    end
  end
  describe "DELETE destroy" do
    it "should be able to destroy a release" do
      id = "99"
      Release.should_receive(:find).with(id).and_return release
      release.should_receive(:destroy)
      user.groups << "super-admin"
      delete :destroy, id:id
      response.should redirect_to releases_url
    end
  end
end