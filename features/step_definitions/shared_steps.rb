Given(/^a user who is logged in$/) do
  @user = FactoryGirl.create(:user)
  step "logged in user"
end

Given "logged in user" do
  visit new_user_session_path(lang: "en")
  fill_in "Email", with: @user.email
  fill_in "Password", with: FactoryGirl.build(:user).password
  click_button "Login"
end