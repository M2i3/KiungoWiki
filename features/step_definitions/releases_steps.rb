Then(/^I search for a release with the query '(.*)'$/) do |query|
  visit releases_path(q:query)
end

Then(/^I should see a "Create It" link button$/) do
  page.should have_link I18n.t('new')
end


Then(/^I should not see the alphabetical index links$/) do
  page.should_not have_link "0..9"
  page.should_not have_link /^A$/
end

When(/^I update and preview a release$/) do
  visit edit_release_path @release
  @title = "New Title"
  fill_in Release.human_attribute_name("title"), with: @title
  click_link I18n.t("preview")
end

Then(/^I should see the release preview listed$/) do
  page.should have_content @title
end

Then(/^the original release should not be touched$/) do
  @release.reload.title.should_not == @title
end