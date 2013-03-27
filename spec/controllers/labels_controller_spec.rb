require 'spec_helper'

describe LabelsController do
  let(:user) { User.new }
  before :each do
    allow_message_expectations_on_nil
  end
  it "should retrieve the users labels on index action" do
    ApplicationController.any_instance.stub(:current_user).and_return user
    request.env['warden'].stub(:authenticate!).and_return user
    labels = [Label.new]
    user.should_receive(:labels).and_return labels
    labels.should_receive(:all).and_return labels
    get :index, format: :json
    response.body.should eq(labels.to_json)
  end

end
