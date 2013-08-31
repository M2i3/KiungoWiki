Feature: Recordings

  As a user who contributes to the site
  I would like edit, add and control content on the wiki
  
  Scenario: A user can search recordings on the wiki and add a new one if the expected result is not found
    Given a recording exists
    And a user who is logged in
    When I search for a recording with the query 'title:"A house of pain"'
    Then I should see a "Create It" link button
    And I should not see the alphabetical index links
  
  @javascript
  Scenario: A user can preview a change before it is saved
    Given a recording exists
    And a user who is logged in
    When I update and preview a recording
    Then I should see the recording preview listed
    And a notice showing that it is a preview
    And the original recording should not be touched