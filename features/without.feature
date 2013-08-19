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
    
  Scenario: Can see which works have no lyrics
    Given works with and without lyrics
    When I go to see works without lyrics
    Then I should see the work without lyrics
    And I should not see the work without lyrics
    
  Scenario: Can see which works have no tags
    Given works with and without tags
    When I go to see works without tags
    Then I should see the work without tags
    And I should not see the work without tags
    
  Scenario: Can see which works have no supplementary sections
    Given works with and without supplementary sections
    When I go to see works without supplementary sections
    Then I should see the work without supplementary sections
    And I should not see the work without supplementary sections
    
  Scenario: Can see which recordings have no artists
    Given recordings with and without artists
    When I go to see recordings without artists
    Then I should see the recording without artists
    And I should not see the recording without artists
    
  Scenario: Can see which recordings have no releases
    Given recordings with and without releases
    When I go to see recordings without releases
    Then I should see the recording without releases
    And I should not see the recording without releases
    
  Scenario: Can see which recordings have no tags
    Given recordings with and without tags
    When I go to see recordings without tags
    Then I should see the recording without tags
    And I should not see the recording without tags
    
  Scenario: Can see which recordings have no supplementary sections
    Given recordings with and without supplementary sections
    When I go to see recordings without supplementary sections
    Then I should see the recording without supplementary sections
    And I should not see the recording without supplementary sections
    