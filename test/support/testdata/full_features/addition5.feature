Feature: Addition

  # Inputs represented as datatable and are supplied as examples
  Scenario Outline: Sum of two numbers

    Given user wants to sum the following numbers:
      | firstNumber   | secondNumber   |
      | <firstNumber> | <secondNumber> |

    When user executes sum function
    Then the sum is <result>

    Examples:
      | firstNumber | secondNumber | result |
      | 10          | 20           | 30     |
      | 50          | 50           | 100    |
      