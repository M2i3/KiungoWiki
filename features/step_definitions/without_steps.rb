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
  page.should_not have_content @with_tags.title
end

Given(/^works with and without supplementary sections$/) do
  @without_sections = FactoryGirl.create(:work, title: "Without tags", missing_supplementary_sections: true)
  @with_sections = FactoryGirl.create(:work, title: "With tags", missing_supplementary_sections: false)
end

Then(/^I should see the work without supplementary sections$/) do
  page.should have_content @without_sections.title
end

Then(/^I should not see the work without supplementary sections$/) do
  page.should_not have_content @with_sections.title
end

Given(/^recordings with and without artists$/) do
  @without_artist = FactoryGirl.create(:recording, title: "Without an Artist")
  recording_artist_link = RecordingArtistWikiLink.new
  recording_artist_link.referenced = FactoryGirl.create(:artist)
  @with_artist = FactoryGirl.create(:recording, artist_wiki_links:[recording_artist_link], title: "With an artist")
end

Then(/^I should see the recording without artists$/) do
  page.should have_content @without_artist.title
end

Then(/^I should not see the recording without artists$/) do
  page.should_not have_content @with_artist.title
end

Given(/^recordings with and without releases$/) do
  @without_release = FactoryGirl.create(:recording, title: "Without a release")
  recording_release_link = RecordingReleaseWikiLink.new
  recording_release_link.referenced = FactoryGirl.create(:release)
  @with_release = FactoryGirl.create(:recording, release_wiki_links:[recording_release_link], title: "With a release")
end

Then(/^I should see the recording without releases$/) do
  page.should have_content @without_release.title
end

Then(/^I should not see the recording without releases$/) do
  page.should_not have_content @with_release.title
end

Given(/^recordings with and without tags$/) do
  @without_tags = FactoryGirl.create(:recording, work_wiki_link_text: "Without tags")
  @with_tags = FactoryGirl.create(:recording, work_wiki_link_text: "With tags")
  @with_tags.tags.build(size: 3, name: "Hello World")
  @with_tags.save!
end

Then(/^I should see the recording without tags$/) do
  page.should have_content @without_tags.title
end

Then(/^I should not see the recording without tags$/) do
  page.should_not have_content @with_tags.title
end

Given(/^recordings with and without supplementary sections$/) do
  @without_sections = FactoryGirl.create(:recording, work_wiki_link_text: "Missing Supplementary Section")
  @with_sections = FactoryGirl.create(:recording, work_wiki_link_text: "Has Supplementary Section", supplementary_sections: [{title: "A section", content:"Its content"}])
end

Then(/^I should see the recording without supplementary sections$/) do
  page.should have_content @without_sections.title
end

Then(/^I should not see the recording without supplementary sections$/) do
  page.should_not have_content @with_sections.title
end