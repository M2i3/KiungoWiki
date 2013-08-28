Feature: Administrative User

  As a administrator of a music wiki site
  I would like to administrate it the way I feel is right
  So that I can give my users a pleasant experience
  
  Scenario: An admin can see destroy links
    Given an admin is logged in
    And an artist, recording, release, and work
    When I visit each of these
    Then I should see a delete link
    
  Scenario: An admin can see the administration section
    Given an admin is logged in
    And an artist, recording, release, and work
    When I visit each of these
    Then I should see an administration section
    
  Scenario: An admin can see the administration section
    Given an admin is logged in
    And an artist, recording, release, and work
    When I visit each of these
    Then I should see an administration section
    
  Scenario: A user cannot see the administration section
    Given a user who is logged in
    And an artist, recording, release, and work
    When I visit each of these
    Then I should not see an administration section
  
  Scenario: Only a super admin can see any of the admin pages
    Given a user who is logged in
    When I go on the users administration page
    Then I should see a Not Authorized error
    
  Scenario: A super-admin can see all the users registered on the wiki
    Given an admin is logged in
    And there are a few users
    When I am on the users administration page
    Then I should see the users of the wiki including myself
    
  Scenario: A super-admin can see a user by clicking on their username in the index
    Given an admin is logged in
    And there are a few users
    When I am on the users administration page
    And I click on a user's name
    Then I can see the user
  
  Scenario: A super-admin can update a user's information
    Given an admin is logged in
    And there are a few users
    When I edit a user's information
    Then the changes should be shown
    
  Scenario: A super-admin can destroy a user
    Given an admin is logged in
    And there are a few users
    When I destroy a user with possessions
    Then their possessions should also be gone
    
    
