Then(/^I should not see a delete link$/) do
  @places_to_vist.each do |place|
    visit place
    page.should_not have_link I18n.t('delete')
  end
end