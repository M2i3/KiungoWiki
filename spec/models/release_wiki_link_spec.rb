require 'spec_helper'

describe ReleaseWikiLink do
  it { should have_field(:item_section).of_type(String) }
  it { should have_field(:item_id).of_type(String) }
  it { should have_field(:track_number).of_type(String) }
  it "should display text nicely" do
    rw = ReleaseWikiLink.new
    rw.reference_text = 'title:"This is a test" media_type:CD'
    rw.objectq_display_text.should == 'This is a test [ media_type:CD ]'
  end
end
