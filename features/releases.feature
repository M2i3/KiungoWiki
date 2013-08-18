Feature: Releases

  As a user who contributes to the site
  I would like edit, add and control content on the wiki
  
  Scenario: A user can search releases on the wiki and add a new one if the expected result is not found
    Given a release exists
    And a user who is logged in
  When I search for a release with the query 'title:"A house of pain"'
  Then I should see a "Create It" link button
  And I should not see the alphabetical index links
