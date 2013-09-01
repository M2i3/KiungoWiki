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

Given(/^I have already performed a preview on an existing artist$/) do
  step 'an artist exists'
  step 'a user who is logged in'
  step 'I update and preview an artist'
  step 'I should see the artist preview listed'
  step 'a notice showing that it is a preview'
  step 'the original artist should not be touched'
end

When(/^I choose to accept the update$/) do
  click_button I18n.t('update')
end

Then(/^the artist should have the new data$/) do
  find('h1', text: @surname)
  @artist.reload.surname.should == @surname
end

When(/^I preview a new artist$/) do
  @surname = "New Surname"
  visit new_artist_path(q:@surname)
  fill_in Artist.human_attribute_name("surname"), with: @surname
  click_link I18n.t("preview")
end

Then(/^no new artist should have been created$/) do
  Artist.all.size.should == 0
end

Given(/^I have already performed a preview for a new artist$/) do
  step 'a user who is logged in'
  step 'I preview a new artist'
  step 'I should see the artist preview listed'
  step 'a notice showing that it is a preview'
  step 'no new artist should have been created'
end

When(/^I choose to accept the creation$/) do
  click_button "Create"
end

Then(/^the artist should have been created$/) do
  find('h1', text: @surname)
  Artist.all.size.should == 1
  Artist.first.surname.should == @surname
end

Given(/^an artist with a supplementary section$/) do
  @artist = FactoryGirl.create(:artist, supplementary_sections: [{title: "A section", content:"Its content"}])
end

When(/^I view this artist$/) do
  visit artist_path @artist
end

Then(/^the report link should be visible$/) do
  page.should have_link I18n.t('report_content')
end

Given(/^an artist without a supplementary section$/) do
  step 'an artist exists'
end

Then(/^the report link should not be visible$/) do
  page.should_not have_link I18n.t('report_content')
end

When(/^I report this resource$/) do
  click_link I18n.t('report_content')
  @name = "Testie"
  @email = "email@email.com"
  @details = "this is mine!"
  @phone = "555-555-5555"
  fill_in I18n.t('report.name'), with: @name
  fill_in I18n.t('report.email'), with: @email
  fill_in I18n.t('report.details'), with: @details
  fill_in I18n.t('report.phone'), with: @phone
  click_button I18n.t('report.submit')
end

Then(/^the administrator and I should receive an email$/) do
  mail = ActionMailer::Base.deliveries.last
  mail.to.should == [ENV['ADMIN_EMAIL']]
  mail.cc.should == [@email]
  [@details, @phone, @name].each do |value|
    mail.body.should include value
  end
end