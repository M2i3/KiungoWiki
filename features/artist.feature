Feature: Artists

  As a user who contributes to the site
  I would like edit, add and control content on the wiki
  
  Scenario: A user can search artists on the wiki and add a new one if the expected result is not found
    Given an artist exists
    And a user who is logged in
    When I search for an artist with the query 'brel'
    Then I should see a "Create It" link button
    And I should not see the alphabetical index links
    
  @javascript
  Scenario: A user can preview a change before it is saved
    Given an artist exists
    And a user who is logged in
    When I update and preview an artist
    Then I should see the artist preview listed
    And a notice showing that it is a preview
    And the original artist should not be touched
    
  @javascript
  Scenario: A user can update a record after a preview
    Given I have already performed a preview on an existing artist
    When I choose to accept the update
    Then the artist should have the new data