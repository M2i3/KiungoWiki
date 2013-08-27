require 'spec_helper'

describe UsersController do
  let(:user) { User.new }
  before :each do
    allow_message_expectations_on_nil
    ApplicationController.any_instance.stub(:current_user).and_return user
    request.env['warden'].stub(:authenticate!).and_return user
  end
  describe "index" do
    it "should let a super admin see all users" do
      user.stub(:groups).and_return ["super-admin"]
      users = []
      User.should_receive(:accessible_by).and_return users
      get :index
      assigns(:users).should eq users
    end
    it "should not let a non-super admin see all users" do
      user.stub(:groups).and_return ["user", "reviewer"]
      expect { get :index }.to raise_error CanCan::AccessDenied
    end
  end
end