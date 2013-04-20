require 'spec_helper'

describe ReleasesHelper do
  it "should be able to return the release of the month" do
    release = Object.new
    Release.should_receive(:first).and_return release
    helper.release_of_the_month.should eq release
  end
  describe "multi_purpose_album_index_title" do
    it "should return the pluralized name" do
      helper.multi_purpose_release_index_title({}).should eq Release.model_name.human.pluralize
    end
    it "should return the pluralized name plus a notice of changes if there is :recent_changes key in the params" do
      helper.multi_purpose_release_index_title({recent_changes: true}).should eq "#{Release.model_name.human.pluralize} modifiees recemment"
    end
  end
  it "should return proper groupings for releases" do
    groupings = helper.alphabetic_release_grouping
    groupings["#"].should eq "0..9"
    ("a".."z").each do |key|
      groupings[key].should eq key.upcase
    end
  end
  it "should be able to " do
    helper.alpha_release_links.should eq alphabetic_release_grouping.collect{|letter, heading|
      link_to heading, alphabetic_releases_path(letter: letter)
    }.join(", ").html_safe
  end
end
