Feature: Some Feature

  Background:

    Given a table as follows
      | A   | B         | C        | D           | E          | F      | G               |
      |a    |b          |c         |d            |e           |f       |g                |
      |    a|          b|         c|            d|           e|       f|                g|
      |     |          b|         c|            d|           e|       f|                g|
      | a   |           | c        |           d |e           |       f|        g        |
      | a   |     b     |          |           d |e           |       f|        g        |
      | a   |     b     |    c     |             |e           |       f|        g        |
      | a   |     b     |    c     |      d      |            |       f|        g        |
      | a   |     b     |    c     |      d      |      e     |        |        g        |
      | a   |     b     |    c     |      d      |      e     |    f   |                 |
      |     |     b     |    c     |      d      |      e     |    f   |                 |
      |     |           |    c     |      d      |      e     |    f   |                 |
      |     |           |    c     |      d      |      e     |        |                 |
      |     |           |    c     |             |      e     |        |                 |
      |     |           |          |             |      e     |        |                 |
      |     |           |          |             |            |        |                 |
      |aaaaa|bbbbbbbbbbb|cccccccccc|ddddddddddddd|eeeeeeeeeeee|ffffffff|ggggggggggggggggg|
      |aaaaa|bbbbbbbbbbb|cccccccccc|             |eeeeeeeeeeee|ffffffff|ggggggggggggggggg|
      |aaaaa|bbbbbbbbbbb|cccccccccc|ddddddddddddd|            |ffffffff|ggggggggggggggggg|
      |aaaaa|           |          |             |            |        |ggggggggggggggggg|
      |aaaaa|           |          |             |            |        |                 |
      |     |           |          |             |            |        |ggggggggggggggggg|
      | | | | | | |ggggggggggggggggg|
| | | | | | |ggggggggggggggggg|
    | | | | | | |ggggggggggggggggg|
        | | | | | | |ggggggggggggggggg|
            | | | | | | |ggggggggggggggggg|
                | | | | | | |ggggggggggggggggg|

    And another table as follows:
      | id  |
      | 401 |
      | |
      ||
      |a           |
      |           b|
      |bbbbbbbbbbbbbbbbbbbbbb|

    When sense is made out of this madness

  Scenario: Some Scenario

    When all the tables are valid
    Then they are all valid
