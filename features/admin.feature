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