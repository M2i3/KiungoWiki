Given(/^works with and without artists$/) do
  @without_artist = FactoryGirl.create(:work, title: "Without an Artist")
  work_artist_link = WorkArtistWikiLink.new
  work_artist_link.referenced = FactoryGirl.create(:artist)
  @with_artist = FactoryGirl.create(:work, artist_wiki_links:[work_artist_link], title: "With an artist")
end

Then(/^I should see the work without an artist$/) do
  page.should have_content @without_artist.title
end

Then(/^I should not see the work with an artist$/) do
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

Then(/^I should not see the work with a recording$/) do
  page.should_not have_content @with_recording.title
end

Given(/^works with and without lyrics$/) do
  @without_lyrics = FactoryGirl.create(:work, title: "Without lyrics", lyrics: "")
  @with_lyrics = FactoryGirl.create(:work, title: "With lyrics", lyrics: "Fa la la")
end

Then(/^I should see the work without lyrics$/) do
  page.should have_content @without_lyrics.title
end

Then(/^I should not see the work with lyrics$/) do
  page.should_not have_content @with_lyrics.title
end

Given(/^works with and without tags$/) do
  @without_tags = FactoryGirl.create(:work, title: "Without tags")
  @with_tags = FactoryGirl.create(:work, title: "With tags")
  @with_tags.tags.build(size: 3, name: "Hello World")
  @with_tags.save!
end

Then(/^I should see the work without tags$/) do
  page.should have_content @without_tags.title
end

Then(/^I should not see the work with tags$/) do
  page.should_not have_content @with_tags.title
end

Given(/^works with and without supplementary sections$/) do
  @without_sections = FactoryGirl.create(:work, title: "Without supplementary sections")
  @with_sections = FactoryGirl.create(:work, title: "With supplementary sections", supplementary_sections: [{title: "A section", content:"Its content"}])
end

Then(/^I should see the work without supplementary sections$/) do
  page.should have_content @without_sections.title
end

Then(/^I should not see the work with supplementary sections$/) do
  page.should_not have_content @with_sections.title
end

Given(/^recordings with and without artists$/) do
  @without_artist = FactoryGirl.create(:recording, work_wiki_link_text: "Without an Artist")
  recording_artist_link = RecordingArtistWikiLink.new(reference_text: "oid:"+FactoryGirl.create(:artist).id.to_s)
  @with_artist = FactoryGirl.create(:recording, artist_wiki_links:[recording_artist_link], work_wiki_link_text: "With an artist")
end

Then(/^I should see the recording without artists$/) do
  page.should have_content @without_artist.title
end

Then(/^I should not see the recording with artists$/) do
  page.should_not have_content @with_artist.title
end

Given(/^recordings with and without releases$/) do
  @without_release = FactoryGirl.create(:recording, work_wiki_link_text: "Without a release")
  recording_release_link = RecordingReleaseWikiLink.new(reference_text: "oid:"+FactoryGirl.create(:release).id.to_s)
  @with_release = FactoryGirl.create(:recording, release_wiki_links:[recording_release_link], work_wiki_link_text: "With a release")
end

Then(/^I should see the recording without releases$/) do
  page.should have_content @without_release.title
end

Then(/^I should not see the recording with releases$/) do
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

Then(/^I should not see the recording with tags$/) do
  page.should_not have_content @with_tags.title
end

Given(/^recordings with and without supplementary sections$/) do
  @without_sections = FactoryGirl.create(:recording, work_wiki_link_text: "Missing Supplementary Section")
  @with_sections = FactoryGirl.create(:recording, work_wiki_link_text: "Has Supplementary Section", supplementary_sections: [{title: "A section", content:"Its content"}])
end

Then(/^I should see the recording without supplementary sections$/) do
  page.should have_content @without_sections.title
end

Then(/^I should not see the recording with supplementary sections$/) do
  page.should_not have_content @with_sections.title
end

Given(/^artists with and without work$/) do
  @without_work = FactoryGirl.create(:artist, surname: "Without a work")
  artist_work_link = ArtistWorkWikiLink.new
  artist_work_link.referenced = FactoryGirl.create(:work)
  @with_work = FactoryGirl.create(:artist, work_wiki_links:[artist_work_link], surname: "With a work")
end

Then(/^I should see the artist without work$/) do
  page.should have_content @without_work.surname
end

Then(/^I should not see the artist with work$/) do
  page.should_not have_content @with_work.surname
end

Given(/^artists with and without releases$/) do
  @without_releases = FactoryGirl.create(:artist, surname: "Without a release")
  artist_release_link = ArtistReleaseWikiLink.new
  artist_release_link.referenced = FactoryGirl.create(:release)
  @with_releases = FactoryGirl.create(:artist, release_wiki_links:[artist_release_link], surname: "With a release")
end

Then(/^I should see the artist without releases$/) do
  page.should have_content @without_releases.surname
end

Then(/^I should not see the artist with releases$/) do
  page.should have_content @with_releases.surname
end

Given(/^artists with and without recordings$/) do
  @without_recordings = FactoryGirl.create(:artist, surname: "Without a recording")
  artist_recoding_link = ArtistRecordingWikiLink.new
  artist_recoding_link.referenced = FactoryGirl.create(:recording)
  @with_recordings = FactoryGirl.create(:artist, recording_wiki_links:[artist_recoding_link], surname: "With a recording")
end

Then(/^I should see the artist without recordings$/) do
  page.should have_content @without_recordings.surname
end

Then(/^I should not see the artist with recordings$/) do
  page.should_not have_content @with_recordings.surname
end

Given(/^artists with and without supplementary sections$/) do
  @without_sections = FactoryGirl.create(:artist, surname: "Missing Supplementary Section")
  @with_sections = FactoryGirl.create(:artist, surname: "Has Supplementary Section", supplementary_sections: [{title: "A section", content:"Its content"}])
end

Then(/^I should see the artist without supplementary sections$/) do
  page.should have_content @without_sections.surname
end

Then(/^I should not see the artist with supplementary sections$/) do
  page.should_not have_content @with_sections.surname
end

Given(/^releases with and without artists$/) do
  @without_artists = FactoryGirl.create(:release, title: "Without an artist")
  release_artist_link = ReleaseArtistWikiLink.new
  release_artist_link.referenced = FactoryGirl.create(:artist)
  @with_artists = FactoryGirl.create(:release, artist_wiki_links:[release_artist_link], title: "With an artist")
end

Then(/^I should see the release without artists$/) do
  page.should have_content @without_artists.title
end

Then(/^I should not see the release with artists$/) do
  page.should_not have_content @with_artists.title
end

Given(/^releases with and without recordings$/) do
  @without_recordings = FactoryGirl.create(:release, title: "Without a recording")
  release_recording_link = ReleaseRecordingWikiLink.new
  release_recording_link.referenced = FactoryGirl.create(:recording)
  @with_recordings = FactoryGirl.create(:release, recording_wiki_links:[release_recording_link], title: "With a recording")
end

Then(/^I should see the release without recordings$/) do
  page.should have_content @without_recordings.title
end

Then(/^I should not see the release with recordings$/) do
  page.should_not have_content @with_recordings.title
end

Given(/^releases with and without supplementary sections$/) do
  @without_sections = FactoryGirl.create(:release, title: "Missing Supplementary Section")
  @with_sections = FactoryGirl.create(:release, title: "Has Supplementary Section", supplementary_sections: [{title: "A section", content:"Its content"}])
end

Then(/^I should see the release without supplementary sections$/) do
  page.should have_content @without_sections.title
end

Then(/^I should not see the release with supplementary sections$/) do
  page.should_not have_content @with_sections.title
end