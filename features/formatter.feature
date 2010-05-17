Feature: Scout formatter
  As a Scout user
  I want to receive reports of failing cucumber features
  In order to protect revenue

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /failing/ do
        raise 'FAIL'
      end

      Given /pending/ do
        pending
      end

      Given /passing/ do
      end
      """
    And a file named "features/one_failure.feature" with:
      """
      Feature: One Failure

        Scenario: Failing
          Given failing

        Scenario: Missing
          Given missing

        Scenario: Pending
          Given pending

        Scenario: Passing
          Given passing
      """
    And a file named "features/multiple_failures.feature" with:
      """
      Feature: Multiple Failures

        Scenario: Failing
          Given failing

        Scenario: Failing2
          Given failing

        Scenario: Failing3
          Given failing

        Scenario: Passing
          Given passing
      """
    And a file named "features/all_passing.feature" with:
      """
      Feature: All Passing

        Scenario: Passing
          Given passing

        Scenario: Passing2
          Given passing

      """

  Scenario: One Failing Feature
    When I run cucumber -r ../../../lib -r features/step_definitions -f Cucumber::Formatter::Scout features/one_failure.feature
    Then it should fail with
      """
      --- 
      :status_counts: 
        :passed: 1
        :failed: 1
        :missing: 1
        :pending: 1
      :failing:
      - |

        Scenario: Failing
          Given failing

      """
  Scenario: Multiple Failing Features
    When I run cucumber -r ../../../lib -r features/step_definitions -f Cucumber::Formatter::Scout features/multiple_failures.feature
    Then it should fail with
      """
      --- 
      :status_counts: 
        :passed: 1
        :failed: 3
      :failing:
      - |

        Scenario: Failing
          Given failing
      - |

        Scenario: Failing2
          Given failing
      - |

        Scenario: Failing3
          Given failing
      
      """

  Scenario: All Features Passing
    When I run cucumber -r ../../../lib -r features/step_definitions -f Cucumber::Formatter::Scout features/all_passing.feature
    Then it should pass with
      """
      --- 
      :status_counts: 
        :passed: 2
      
      """