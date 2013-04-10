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
end
