Given(/^a recording exists$/) do
  FactoryGirl.create(:recording)
end

When(/^I search for a recording with the query '(.*)'$/) do |query|
  visit recordings_path(q:query)
end