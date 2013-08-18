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