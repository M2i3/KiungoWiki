require 'spec_helper'

describe Admin::UsersController do
  let(:user) { User.new }
  before :each do
    allow_message_expectations_on_nil
    ApplicationController.any_instance.stub(:current_user).and_return user
    request.env['warden'].stub(:authenticate!).and_return user
  end
  describe "index" do
    it "should let a super admin see all users" do
      user.groups =  ["super-admin"]
      get :index
      assigns(:users).should eq []
    end
  end
end