Feature: Works

  As a user who contributes to the site
  I would like edit, add and control content on the wiki
  
  Scenario: A user can search works on the wiki and add a new one if the expected result is not found
    Given a work exists
    And a user who is logged in
    When I search for a work with the query 'title:"A house of pain"'
    Then I should see a "Create It" link button
    And I should not see the alphabetical index links
    
  @javascript
  Scenario: A user can preview a change before it is saved
    Given a work exists
    And a user who is logged in
    When I update and preview a work
    Then I should see the work preview listed
    And a notice showing that it is a preview
    And the original work should not be touched
    
  @javascript
  Scenario: A user can update a record after a preview
    Given I have already performed a preview on an existing work
    When I choose to accept the update
    Then the work should have the new data
    
  @javascript
  Scenario: A user can preview a new record before saving
    Given a user who is logged in
    When I preview a new work
    Then I should see the work preview listed
    And a notice showing that it is a preview
    And no new work should have been created