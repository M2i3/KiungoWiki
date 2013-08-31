Given(/^an artist exists$/) do
  @artist = FactoryGirl.create(:artist)
end

When(/^I search for an artist with the query '(.*)'$/) do |query|
  visit artists_path(q:query)
end

When(/^I update and preview an artist$/) do
  visit edit_artist_path @artist
  @surname = "New Surname"
  fill_in Artist.human_attribute_name("surname"), with: @surname
  click_link I18n.t("preview")
end

Then(/^I should see the artist preview listed$/) do
  page.should have_content @surname
end

Then(/^a notice showing that it is a preview$/) do
  page.should have_content I18n.t("preview_warning")
end

Then(/^the original artist should not be touched$/) do
  @artist.reload.surname.should_not == @surname
end