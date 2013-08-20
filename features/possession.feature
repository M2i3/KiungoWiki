Feature: Possessions

  As a user who owns many releases
  I would like to express that I own an release
  So that I can share with others on my musical taste
  
  @javascript
  Scenario: A user can add releases to their collections
    Given a release exists
    And a user who is logged in
    And I go to a release
    When I click on "Add to My Music" and confirm
    Then I should see "Already in My Music"
    And the release should be in my possession
  
  @javascript
  Scenario: A user can label their possessions
    Given a user who is logged in and looking at a release
    When I add this release to my collection
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
    Given a release exists
    And a user who is logged in
    And I go to new possession
    When I fill in possession info and submit
    Then I should see my new possession
