Given(/^a work exists$/) do
  @work = FactoryGirl.create(:work)
end

When(/^I search for a work with the query '(.*)'$/) do |query|
  visit works_path(q:query)
end

When(/^I update and preview a work$/) do
  visit edit_work_path @work
  @title = "New Title"
  fill_in Artist.human_attribute_name("title"), with: @title
  click_link I18n.t("preview")
end

Then(/^I should see the work preview listed$/) do
  page.should have_content @title
end

Then(/^the original work should not be touched$/) do
  @work.reload.title.should_not == @title
end