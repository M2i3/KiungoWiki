Given(/^an artist exists$/) do
  FactoryGirl.create(:artist)
end

When(/^I search for an artist with the query '(.*)'$/) do |query|
  visit artists_path(q:query)
end