defmodule UtilsTest do
  @moduledoc false

  use ExUnit.Case

  alias Gherkin.Scanner.Utils

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
