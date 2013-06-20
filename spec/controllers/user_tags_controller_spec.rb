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
    [Artist, Work, Release, Recording].each do |klass|
      klass.stub(:find).and_return resource
    end
    resource.stub(:id).and_return 99
    resource.stub(:user_tags).and_return resource
    tag.stub(:id).and_return 99
    tag.stub(:taggable).and_return resource
  end
  
  describe "PUT update" do
    it "can create with valid params" do
      resource.should_receive(:user_tags_text).and_return resource
      resource.should_receive(:[]=)
      put :update, user_tag: {}, format: :json, id:99.to_param
      response.status.should eq(201)
    end
  end
  
  describe "GET lookup" do
    it "can look up their user tags" do
      tags = [tag]
      name = "test"
      tag.stub(:name).and_return name
      user.should_receive(:user_tags).and_return tags
      tags.should_receive(:where).with(name:/#{name}/i).and_return tags
      get :lookup, format: :json, q:name
      response.body.should eq [{id:name, name:name}, {id:name, name:"#{name} (nouveau)"}].to_json
    end
  end
end
