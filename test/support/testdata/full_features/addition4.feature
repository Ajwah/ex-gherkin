Feature: Addition

  # Inputs are supplied as examples, there are 2 examples '10 + 20 = 30', '50 + 60 = 110'
  Scenario Outline: Sum of two numbers - version 5

    Given first number is <firstNumber>
    And second number is <secondNumber>
    When user executes sum function
    Then the sum is <result>

    Examples:
      | firstNumber | secondNumber | result |
      | 10          | 20           | 30     |
      | 50          | 60           | 110    |
      