Feature: Addition

  # Inputs first number and second number are split into 2 lines
  Scenario: Sum of two numbers

    Given first number is 10
    And second number is 20
    When user executes sum function
    Then the sum is 30
    