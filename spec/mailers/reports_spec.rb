require "spec_helper"

describe Reports do
  describe "claim" do
    let(:entity) { FactoryGirl.create(:artist) }
    let(:name) { "Joe Schmoe" }
    let(:email) { "joe@test.com" }
    let(:details) { "My song!" }
    let(:phone) { "8675309" }
    let(:params) { {name: name, email: email, phone: phone, details: details} }
    let(:mail) { Reports.claim(entity, entity.name, artist_url(entity), params) }

    it "renders the headers" do
      mail.subject.should eq "Removal Request for #{entity.class} - #{entity.name}"
      if ENV['ADMIN_EMAIL']
        mail.to.should include admin_email
      else
        mail.to.size.should == 0
      end
      mail.cc.should include email
    end
    
    it "renders the body" do
      [details, name, email, phone, artist_url(entity), entity.name].each do |value|
        mail.body.encoded.should include value
      end
    end
  end

end
