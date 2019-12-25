# language: en

@first_tag @second_tag
    @third_tag

# This is a random comment interspersing our tags for some
# informant reason


@tag1 @tag2  @tag3   @tag4
Feature: Some feature
In an attempt to assert that every Gherkin keyword is being
parsed correctly, this feature with all possible permutations
is being coined.

Top to bottom we should have following structure:
    language
    feature-tags
    feature with title
    feature-description
    background
        with title
        with description
        various scenarios/scenario-outlines
        with/without title
        with/without description
        with/without scenario-tags
        variety of steps
        with/without step-argument(DocString or DataTable)
        with/without multiple Examples
            with/without tags
            with/without multiple DataTables
    various rules
        with/without title
        with/without background

# This represents the Background
Background: a simple background
    There can only be one Background.

    As such, we add description and title to show that it works

    Given a simple data table
    | foo | bar |
    | boz | boo |
    | boz | boo |
    | boz | boo |
    | boz | boo |

# This one is a Scenario
@tag4@tag5@tag6@tag7@tag8@tag9@tag10
Scenario: First Scenario
    This is a legit description
    It pertains to a few things

    Given 1
    ```ruby
    1 + 1
    ```
    And 2
    # Here is a step with DocString as Step Arg
    When 3
    """
    This pertains to When
    """
    Then 4

Scenario: Second Scenario
    Given A
    When B
    And C
    """ruby
    1 + 1
    """
    Then D
    """elixir
    1 + 1
    """

Scenario: Third Scenario
    Here we have a Scenario with multiple `Given`s

    Some of them even contain a DocString as a Step Argument

    Given 1
    Given 2
    """ruby
    1 + 1
    """
    Given 3
    Given 4

Scenario:
    Given a scenario without title <what>

    @foo
    # Here we coin multiple examples
    Examples:
    In a turn of events, foo is neeeded
    | what |
    | foo  |

    @bar
    Examples:
    | what |
    | bar  |

Scenario Outline: 1
    Given the <who>

    Examples:
    | who       |
    | Bob |

Scenario Outline: 2
    Given the <what>

    Examples:
    | what       |
    | minimalism |

@some_random_tag
Scenario Outline: 3
    Given the <where>

    Examples:
    | where       |
    | USA |

Scenario Outline: 4
    This Scenario Outline aims to exemplify usage of
    multiple Examples

    These Examples are being tagged

    Given the <why>

    @examples_tag1
    Examples:
    | why       |
    | for the lolz |

    @examples_tag2
    Examples:
    | why       |
    | for the lolz |


Scenario Outline:
    Given scenario outline without title <why>

    @examples_tag1
    # Examples without a DataTable
    Examples:

    @examples_tag2
    Examples:
    | why       |
    | for the lolz |

Rule: This one has a title




Rule: This one has a title and a description
    This is a description for a specific rule

    is it a nice description?
Rule: This one has background as well
    Background: But no content
Rule: This one has background as well
    Background: At least a description
    Here is a short concise description

            is all ok?
    or are there any inconsistencies?

Rule: This one has background as well
    In order to ensure that Background is supported, we introduce

        the same over here

    Background:
    No title for this background

    Given a simple data table
    | foo | bar |
    | boz | boo |
    | boz | boo |
    | boz | boo |
    | boz | boo |

    @tag4@tag5@tag6@tag7@tag8@tag9@tag10
    Scenario: First Scenario
    This is a legit description
    It pertains to a few things

    Given 1
    ```ruby
    1 + 1
    ```
    And 2
    When 3
    """
    This pertains to When
    """
    Then 4

    Scenario: Second Scenario
    Given A
    When B
    And C
    """ruby
    1 + 1
    """
    Then D
    """elixir
    1 + 1
    """

    Scenario: Third Scenario
    Here we have a Scenario with multiple `Given`s

    Some of them even contain a DocString as a Step Argument

    Given 1
    Given 2
    """ruby
    1 + 1
    """
    Given 3
    Given 4

    Scenario:
    Given a scenario without title <what>

    @foo
    Examples:
        In a turn of events, foo is neeeded
        | what |
        | foo  |

    @bar
    Examples:
        | what |
        | bar  |

    Scenario Outline: 1
    Given the <who>

    Examples:
        | who       |
        | Bob |

    Scenario Outline: 2
    Given the <what>

    Examples:
        | what       |
        | minimalism |

    @some_random_tag
    Scenario Outline: 3
    Given the <where>

    Examples:
        | where       |
        | USA |

    Scenario Outline: 4
    This Scenario Outline aims to exemplify usage of
    multiple Examples

    These Examples are being tagged

    Given the <why>

    @examples_tag1
    Examples:
        | why       |
        | for the lolz |

    @examples_tag2
    Examples:
        | why       |
        | for the lolz |


    Scenario Outline:
    Given scenario outline without title <why>

    @examples_tag1
    Examples:
        | why       |
        | for the lolz |

    @examples_tag2
    Examples:
        | why       |
        | for the lolz |