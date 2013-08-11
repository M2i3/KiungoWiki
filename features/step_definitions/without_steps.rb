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