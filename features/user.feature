Feature: User

  As a user of a music wiki site
  I would like to use the site the way I feel is right
  So that I can have a pleasant experience
  
  Background: A user is logged in with some resources already in the database
    Given a user who is logged in
    And an artist, recording, release, and work
  
  Scenario: A normal user cannot see destroy links
    When I visit each of these
    Then I should not see a delete link
  
  @javascript
  Scenario: A normal user cannot see destroy links
    When I visit each of these
    Then I should be able to tag them