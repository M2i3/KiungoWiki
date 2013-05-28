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
  [@artist, @recording, @release, @work].each do |resource|
    UserTag.where(name:tag, user:@user, taggable_id:resource.id, taggable_type:resource.class.to_s).size.should == 1
  end
end