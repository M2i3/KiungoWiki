Given(/^a user who is logged in$/) do
  @user = FactoryGirl.create(:user)
  visit new_user_session_path(lang: "en")
  fill_in "Email", with: @user.email
  fill_in "Password", with: FactoryGirl.build(:user).password
  click_button "Connexion"
end

Given(/^an album exists$/) do
  FactoryGirl.create(:album)
end

When(/^I click on "(.*?)" and confirm$/) do |link|
  click_link link
  find('div.ui-dialog')
  click_button link
end

Then(/^the album should be in my possession$/) do
  Possession.where(owner_id: @user.id).all.size.should eq 1
end