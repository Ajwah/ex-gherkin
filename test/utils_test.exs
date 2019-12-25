defmodule UtilsTest do
  @moduledoc false

  use ExUnit.Case

  alias ExGherkin.Scanner.Utils

  def data_table_pipe_splitter(line, offset) do
    line
    |> String.trim("|")
    |> Utils.data_table_pipe_splitter(offset)
  end

  describe "#data_table_pipe_splitter splits while maintaining column position" do
    test "Splits by pipes" do
      assert [{2, "a"}, {4, "b   "}, {12, "c"}, {15, "d  "}] ==
               data_table_pipe_splitter("|a|b   |   c| d  |", 1)
    end

    test "Splits by pipes with no cell content" do
      assert [{2, "a"}, {4, "b   "}, {9, ""}, {13, "c"}, {16, "d  "}] ==
               data_table_pipe_splitter("|a|b   ||   c| d  |", 1)
    end

    test "Splits by pipes with only whitespace cell content" do
      actual =
        """
        | id  | type   | isdCode | phoneNumber | extension |
        | 401 | Mobile | +1      | 2141112222  |           |
        | 402 | Office | +1      | 8362223000  | 333       |
        | 403 | Other  |         | 8362223000  |           |
        """
        |> String.split("\n", trim: true)
        |> Enum.map(&data_table_pipe_splitter(&1, 1))

      expected = [
        [{3, "id  "}, {9, "type   "}, {18, "isdCode "}, {28, "phoneNumber "}, {42, "extension "}],
        [{3, "401 "}, {9, "Mobile "}, {18, "+1      "}, {28, "2141112222  "}, {52, ""}],
        [{3, "402 "}, {9, "Office "}, {18, "+1      "}, {28, "8362223000  "}, {42, "333       "}],
        [{3, "403 "}, {9, "Other  "}, {26, ""}, {28, "8362223000  "}, {52, ""}]
      ]

      assert expected == actual
    end

    test "Leaves newline character unmolested" do
      assert [{2, "a"}, {4, "b   "}, {10, "\n  c"}, {17, "d  "}] ==
               data_table_pipe_splitter("|a|b   | \n  c| d  |", 1)
    end

    test "Leaves \\ unmolested" do
      assert [{2, "a"}, {4, "b   "}, {10, "\\  c"}, {17, "d  "}] ==
               data_table_pipe_splitter("|a|b   | \\  c| d  |", 1)
    end

    test "Treats escaped pipe `\\|` as cell content" do
      assert [{2, "a"}, {4, "b   "}, {10, "|  c"}, {17, "d  "}] ==
               data_table_pipe_splitter("|a|b   | \\|  c| d  |", 1)
    end

    test "First cell content indented right" do
      assert [{6, "red   "}] == data_table_pipe_splitter("|    red   |", 1)
    end

    test "Indentation with tabs" do
      assert [{5, "red "}] == data_table_pipe_splitter("|  	red  	|", 1)
    end

    test "Handles combinations of \\, \n and \\| properly" do
      assert [{3, "|æ\\n     "}, {16, "\\o\no\\   "}] ==
               data_table_pipe_splitter("| \\|æ\\\\n     | \\o\\no\\   |", 1)

      assert [{3, "\\|a\\\\n "}, {16, "ø\\\nø\\   "}] ==
               data_table_pipe_splitter("| \\\\\\|a\\\\\\\\n | ø\\\\\\nø\\\\   |", 1)
    end
  end
end
