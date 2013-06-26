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
end
