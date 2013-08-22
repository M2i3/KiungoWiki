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

Given(/^there are a few users$/) do
  @users = FactoryGirl.create_list(:user, 5) 
end

Then(/^I should see the users of the wiki including myself$/) do
  @users.each {|user|
    page.should have_content user.nickname
    page.should have_content user.email
    page.should have_content user.groups.join(", ")
  }
end