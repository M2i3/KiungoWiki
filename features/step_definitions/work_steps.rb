Given(/^a work exists$/) do
  FactoryGirl.create(:work)
end

When(/^I search for a work with the query '(.*)'$/) do |query|
  visit works_path(q:query)
end