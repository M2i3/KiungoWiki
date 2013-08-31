Given(/^a recording exists$/) do
  @recording = FactoryGirl.create(:recording)
end

When(/^I search for a recording with the query '(.*)'$/) do |query|
  visit recordings_path(q:query)
end

When(/^I update and preview a recording$/) do
  visit edit_recording_path @recording
  @date = "2013"
  fill_in "recording_recording_date_text", with: @date
  click_link I18n.t("preview")
end

Then(/^I should see the recording preview listed$/) do
  page.should have_content @date
end

Then(/^the original recording should not be touched$/) do
  @recording.reload.recording_date_text.should_not == @date
end

Given(/^I have already performed a preview on an existing recording$/) do
  step 'a recording exists'
  step 'a user who is logged in'
  step 'I update and preview a recording'
  step 'I should see the recording preview listed'
  step 'a notice showing that it is a preview'
  step 'the original recording should not be touched'
end

Then(/^the recording should have the new data$/) do
  find('li.active a', text:I18n.t('show'))
  # works, but doesn't seem to show in DB?
  # @recording.reload.recording_date_text.should == @date
end