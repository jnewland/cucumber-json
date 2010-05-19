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
    Then the output should contain "output[:status_counts][:failed]" set to "1"
    And the output should contain "output[:status_counts][:passed]" set to "1"
    And the output should contain "output[:status_counts][:undefined]" set to "1"
    And the output should contain "output[:status_counts][:pending]" set to "1"
  Scenario: Multiple Failing Features
    When I run cucumber -r ../../../lib -r features/step_definitions -f Cucumber::Formatter::Scout features/multiple_failures.feature
    Then the output should contain "output[:status_counts][:failed]" set to "3"
    And the output should contain "output[:status_counts][:passed]" set to "1"

  Scenario: All Features Passing
    When I run cucumber -r ../../../lib -r features/step_definitions -f Cucumber::Formatter::Scout features/all_passing.feature
    Then the output should contain "output[:status_counts][:passed]" set to "2"