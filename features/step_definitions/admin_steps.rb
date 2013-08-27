Given(/^an admin is logged in$/) do
  @user = FactoryGirl.create(:user, groups:["super-admin"])
  step "logged in user"
end

Given(/^an artist, recording, release, and work$/) do
  @artist = FactoryGirl.create(:artist)
  @recording = FactoryGirl.create(:recording)
  @release = FactoryGirl.create(:release)
  @work = FactoryGirl.create(:work)
end

When(/^I visit each of these$/) do
  @places_to_vist = [artist_path(@artist, lang: "en"), recording_path(@recording, lang: "en"), release_path(@release, lang: "en"), work_path(@work, lang: "en")]
end

Then(/^I should see a delete link$/) do
  @places_to_vist.each do |place|
    visit place
    page.should have_link I18n.t('delete')
  end
end

Then(/^I should see an administration section$/) do
  @places_to_vist.each do |place|
    visit place
    page.should have_content I18n.t("administration")
  end
end

Then(/^I should not see an administration section$/) do
  @places_to_vist.each do |place|
    visit place
    page.should_not have_content I18n.t("administration")
  end
end