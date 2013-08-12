Feature: Resources missing data

  As a contributer of a music wiki site
  I would like to see which resources are missing crucial data
  So that the community can have more complete data
  
  Scenario: Can see which works have no artists
    Given works with and without artists
    When I go to see works without artists
    Then I should see the work without an artist
    And I should not see the work without an artist
    
  Scenario: Can see which works have no recordings
    Given works with and without recordings
    When I go to see works without recordings
    Then I should see the work without a recording
    And I should not see the work without a recording
    