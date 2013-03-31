require 'spec_helper'

describe Ability do
  let(:ability) { Ability.new(user) }
  let(:user) { User.new }
  context "Possession" do
    let(:possession) { Possession.new }
    context "different owners" do
      before :each do
        possession.owner = User.new
      end
      it "won't let you edit if you are not that user's owner" do
        ability.should_not be_able_to :edit, possession
      end
      it "won't let you update if you are not that user's owner" do
        ability.should_not be_able_to :update, possession
      end
      it "won't let you destroy if you are not that user's owner" do
        ability.should_not be_able_to :destroy, possession
      end
      it "won't let you see other's possessions" do
        ability.should_not be_able_to :show, possession
      end
      it "cannot let all logged in users create a possession" do
        ability.should_not be_able_to :create, possession
      end
    end
    context "same owner" do
      before :each do
        possession.owner = user
      end
      it "can let you edit if you are that possession's owner" do
        ability.should be_able_to :edit, possession
      end
      it "can let you update if you are that possession's owner" do
        ability.should be_able_to :update, possession
      end
      it "can let you destroy if you are that possession's owner" do
        ability.should be_able_to :destroy, possession
      end
      it "can let all users read each others possessions" do
        ability.should be_able_to :show, possession
      end
      it "can let all logged in users create a possession" do
        ability.should be_able_to :create, possession
      end
    end
  end
end