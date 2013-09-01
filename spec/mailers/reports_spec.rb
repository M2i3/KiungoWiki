require "spec_helper"

describe Reports do
  describe "claim" do
    let(:mail) { Reports.claim }

    # it "renders the headers" do
    #   mail.subject.should eq("Claim")
    #   mail.to.should eq(["to@example.org"])
    #   mail.from.should eq(["from@example.com"])
    # end
    # 
    # it "renders the body" do
    #   mail.body.encoded.should match("Hi")
    # end
  end

end
