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
  
  @javascript  
  Scenario: A user can label their possessions
    Given a user who is logged in and looking at an album
    When I add this album to my collection
    And I fill in a few labels
    Then my possession should be labeled
    
  Scenario: A user can see all of their possessions
    Given a user with multiple possessions who logs in
    When I go to My Music
    Then I should see all of my possessions
    
  Scenario: A user can remove possessions
    Given a user with multiple possessions who logs in
    When I go to My Music
    And I remove a random possession
    Then it should not be shown in My Music
  
  @javascript  
  Scenario: A user can add a possession through the My Music section
    Given an album exists
    And a user who is logged in
    And I go to new possession
    When I fill in posession info and submit
    Then I should see my new possession