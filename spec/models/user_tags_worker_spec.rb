require 'spec_helper'

describe UserTagsWorker do
  let(:taggable) { Artist.new }
  let(:worker) { UserTagsWorker.new taggable }
  let(:user) { User.new }
  it "should require a taggable object upon creation" do
    expect { UserTagsWorker.new }.to raise_error
  end
  describe "instance" do
    before :each do
      taggable.should_receive(:user_tags).at_least(1).and_return taggable
      @tag1 = "tag1"
      @tag2 = "tag2"
    end
    it "should set the taggable's tags with the current_user as the key" do
      taggable.should_receive(:destroy_all).with(user:user)
      taggable.should_receive(:create!).with(name:@tag1, user:user)
      taggable.should_receive(:create!).with(name:@tag2, user:user)
      worker[user] = "#{@tag1},#{@tag2}"
    end
    it "should return the values expected" do
      tag1 = Object.new
      tag2 = Object.new
      tag1.stub(:name).and_return @tag1
      tag2.stub(:name).and_return @tag2
      taggable.should_receive(:where).with(user:user).and_return [tag1,tag2]
      worker[user].should eq "#{@tag1},#{@tag2}"
    end
  end
end