Given(/^a work exists$/) do
  @work = FactoryGirl.create(:work, lyrics: "")
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

Given(/^I have already performed a preview on an existing work$/) do
  step 'a work exists'
  step 'a user who is logged in'
  step 'I update and preview a work'
  step 'I should see the work preview listed'
  step 'a notice showing that it is a preview'
  step 'the original work should not be touched'
end

Then(/^the work should have the new data$/) do
  find('h1', text:@title)
  @work.reload.title.should == @title
end

When(/^I preview a new work$/) do
  @title = "New Title"
  visit new_work_path q:@title
  fill_in Artist.human_attribute_name("title"), with: @title
  click_link I18n.t("preview")
end

Then(/^no new work should have been created$/) do
  Work.all.size.should == 0
end

Given(/^a work with a supplementary section$/) do
  @work = FactoryGirl.create(:work, title: "With supplementary sections", supplementary_sections: [{title: "A section", content:"Its content"}])
end

When(/^I view this work$/) do
  visit work_path @work
end

Given(/^a work without a supplementary section$/) do
  step 'a work exists'
end

Given(/^a work with lyrics$/) do
  @work = FactoryGirl.create(:work, title: "With lyrics", lyrics: "Fa la la")
end