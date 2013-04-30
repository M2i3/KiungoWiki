Feature: User

  As a administrator of a music wiki site
  I would like to administrate it the way I feel is right
  So that I can give my users a pleasant experience
  
  Scenario: A normal user cannot see destroy links
    Given a user who is logged in
    And an artist, recording, release, and work
    When I visit each of these
    Then I should not see a delete link