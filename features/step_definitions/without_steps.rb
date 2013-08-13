Given(/^works with and without artists$/) do
  @without_artist = FactoryGirl.create(:work, title: "Without an Artist")
  work_artist_link = WorkArtistWikiLink.new
  work_artist_link.referenced = FactoryGirl.create(:artist)
  @with_artist = FactoryGirl.create(:work, artist_wiki_links:[work_artist_link], title: "With an artist")
end

Then(/^I should see the work without an artist$/) do
  page.should have_content @without_artist.title
end

Then(/^I should not see the work without an artist$/) do
  page.should_not have_content @with_artist.title
end

Given(/^works with and without recordings$/) do
  @without_recording = FactoryGirl.create(:work, title: "Without a recording")
  work_recording_link = WorkRecordingWikiLink.new
  work_recording_link.referenced = FactoryGirl.create(:recording)
  @with_recording = FactoryGirl.create(:work, recording_wiki_links:[work_recording_link], title: "With a recording")
end

Then(/^I should see the work without a recording$/) do
  page.should have_content @without_recording.title
end

Then(/^I should not see the work without a recording$/) do
  page.should_not have_content @with_recording.title
end

Given(/^works with and without lyrics$/) do
  @without_lyrics = FactoryGirl.create(:work, title: "Without lyrics", lyrics: "")
  @with_lyrics = FactoryGirl.create(:work, title: "With lyrics", lyrics: "Fa la la")
end

Then(/^I should see the work without lyrics$/) do
  page.should have_content @without_lyrics.title
end

Then(/^I should not see the work without lyrics$/) do
  page.should_not have_content @with_lyrics.title
end

Given(/^works with and without tags$/) do
  @without_tags = FactoryGirl.create(:work, title: "Without tags", missing_tags: true)
  @with_tags = FactoryGirl.create(:work, title: "With tags", missing_tags: false)
end

Then(/^I should see the work without tags$/) do
  page.should have_content @without_tags.title
end

Then(/^I should not see the work without tags$/) do
  page.should have_content @with_tags.title
end

Given(/^works with and without supplementary sections$/) do
  @without_sections = FactoryGirl.create(:work, title: "Without tags", missing_supplementary_sections: true)
  @with_sections = FactoryGirl.create(:work, title: "With tags", missing_supplementary_sections: false)
end

Then(/^I should see the work without supplementary sections$/) do
  page.should have_content @without_sections.title
end

Then(/^I should not see the work without supplementary sections$/) do
  page.should have_content @with_sections.title
end