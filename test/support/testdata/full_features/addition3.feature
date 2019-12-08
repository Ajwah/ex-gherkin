Feature: Addition

  # Using Cucumber DataTable to get all inputs - addition of 3 numbers
  Scenario: Sum of multiple numbers

    Given user wants to sum the following numbers:
      | 10 |
      | 20 |
      | 30 |
    When user executes sum function
    Then the sum is 60
    