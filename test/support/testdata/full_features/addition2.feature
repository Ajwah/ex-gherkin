Feature: Addition

  # Using Cucumber DataTable to get all inputs
  Scenario: Sum of two numbers

    Given user wants to sum the following numbers:
      | 10 |
      | 20 |
    When user executes sum function
    Then the sum is 30
    