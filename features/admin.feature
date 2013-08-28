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
