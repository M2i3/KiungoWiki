Then(/^I should not see a delete link$/) do
  @places_to_vist.each do |place|
    visit place
    page.should_not have_link I18n.t('delete')
  end
end

Then(/^I should be able to tag them$/) do
  tag = "Test Tag"
  modal = 'div#addtagform.in'
  @places_to_vist.each do |place|
    visit place
    click_link I18n.t('tag')
    page.should have_selector modal
    fill_in UserTag.human_attribute_name("name"), with: tag
    find('a#confirmaddtag', text: I18n.t('new')).click
    page.should_not have_selector modal
  end
  count = 0
  while count < 30
    break if @user.reload.user_tags.all.size > 0
    count += 1
    sleep 1
  end
  @user.user_tags.each do |tag|
    [@artist, @recording, @release, @work].should include tag.taggable
  end
end