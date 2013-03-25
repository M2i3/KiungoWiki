Feature: Possessions

  As a user who owns many albums
  I would like to express that I own an album
  So that I can share with others on my musical taste
  
  @javascript
  Scenario: A user can add albums to their collections
    Given an album exists
    And a user who is logged in
    And I go to an album
    When I click on "Add to My Music" and confirm
    Then I should see "Already in My Music"
    And the album should be in my possession