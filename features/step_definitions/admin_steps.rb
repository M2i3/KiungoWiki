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
  @places_to_vist = [artist_path(@artist), recording_path(@recording), release_path(@release), work_path(@work)]
end

Then(/^I should see a delete link and warning$/) do
  @places_to_vist.each do |place|
    visit place
    click_link I18n.t("administration")
    page.should have_link I18n.t('delete'), href: place
    warning =
    if place == artist_path(@artist)
      I18n.t('messages.delete_artist_warning')
    elsif place == recording_path(@recording)
      I18n.t('messages.delete_recording_warning')
    elsif place == release_path(@release)
      I18n.t('messages.delete_release_warning')
    elsif place == work_path(@work)
      I18n.t('messages.delete_work_warning')
    end
    page.should have_content warning
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

When(/^I click on a user's name$/) do
  @user = @users.first
  click_link @user.nickname
end

Then(/^I can see the user$/) do
  page.should have_content @user.nickname
  page.should have_content @user.email
  page.should have_content @user.groups.join(", ")
end

When(/^I edit a user's information$/) do
  @user = @users.first
  visit edit_admin_user_path @user
  @email = "tester@testies.com"
  fill_in User.human_attribute_name("email"), with: @email
  @nickname = "tester123"
  fill_in User.human_attribute_name("nickname"), with: @nickname
  @groups = ["reviewer"]
  @groups.each {|group| check group.capitalize }
  ['user', 'super-admin'].each {|group| uncheck group.capitalize }
  click_button "Update User"
end

Then(/^the changes should be shown$/) do
  @user.reload.email.should == @email
  @user.nickname.should == @nickname
  @user.groups.should == @groups
  step "I can see the user"
end

When(/^I destroy a user with possessions$/) do
  user = @users.first
  visit edit_admin_user_path user
  @possessions = []
  (1..3).each do |num|
    title = "test#{num}"
    release = FactoryGirl.create(:release, title:title)
    @possessions << Possession.where(release_wiki_link:ReleaseWikiLink.new(release_id:release.id, 
    reference_text:"oid:#{release.id}", title:release.title), owner:user).create!
  end
  click_link I18n.t "delete"
end

Then(/^their possessions should also be gone$/) do
  @possessions.each do |poss|
    expect {Possession.find poss.id}.to raise_error Mongoid::Errors::DocumentNotFound
  end
end