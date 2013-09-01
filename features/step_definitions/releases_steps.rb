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

Given(/^I have already performed a preview on an existing release$/) do
  step 'a release exists'
  step 'a user who is logged in'
  step 'I update and preview a release'
  step 'I should see the release preview listed'
  step 'a notice showing that it is a preview'
  step 'the original release should not be touched'
end

Then(/^the release should have the new data$/) do
  find('h1', text:@title)
  @release.reload.title.should == @title
end

When(/^I preview a new release$/) do
  @title = "New Title"
  visit new_release_path q:@title
  fill_in Release.human_attribute_name("title"), with: @title
  click_link I18n.t("preview")
end

Then(/^no new release should have been created$/) do
  Release.all.size.should == 0
end

Given(/^I have already performed a preview for a new release$/) do
  step 'a user who is logged in'
  step 'I preview a new release'
  step 'I should see the release preview listed'
  step 'a notice showing that it is a preview'
  step 'no new release should have been created'
end

Then(/^the release should have been created$/) do
  find('h1', text:@title)
  Release.all.size.should == 1
  Release.first.title.should == @title
end