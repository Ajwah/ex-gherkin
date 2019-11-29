defmodule ScannerTest do
  use ExUnit.Case
  alias Gherkin.Scanner
  alias Gherkin.Scanner.SyntaxError

  @keywords [
    {"Feature:", :feature},
    {"Rule:", :rule},
    {"Example:", :scenario},
    {"Scenario:", :scenario},
    {"Given", :given},
    {"When", :when},
    {"Then", :then},
    {"But", :but},
    {"And", :and},
    {"Background:", :background},
    {"Scenario Outline:", :scenario_outline},
    {"Scenario Template:", :scenario_outline},
    {"Examples:", :scenarios},
    {"Scenarios:", :scenarios}
  ]

  def tokenize(contents) do
    contents
    |> Scanner.tokenize()
    |> Enum.take(1000)
  end

  describe "#tokenize(list) Recognizes Primitives:" do
    @some_text "This is some text"
    @keywords
    |> Enum.each(fn {textual_syntax, keyword} ->
      test "Gherkin Keyword: `#{textual_syntax}`" do
        assert [{:token, unquote(keyword), {:location, 1, 1}, unquote(@some_text)}] ==
                 tokenize(["#{unquote(textual_syntax)} #{@some_text}"])
      end
    end)

    test "Recognizes Comment: `#`" do
      assert [{:token, :comment, {:location, 1, 1}, " This is some comment"}] == tokenize(["# This is some comment"])
    end

    test "Recognizes Tag: `@`" do
      assert [{:token, :tag, {:location, 1, 1}, ["some_tag"]}] == tokenize(["@some_tag"])
    end

    test "Recognizes Table: `|`" do
      assert [{:token, :data_table, {:location, 1, 1}, ["A", "B", "C"]}] == tokenize(["| A | B | C |"])
    end

    test "Recognizes Docstring: `\"\"\"`" do
      delim = "\"\"\""
      assert [{:token, :doc_string, {:location, 1, 1}, {delim, :plain}} | _] = tokenize([delim, "a", delim])
    end

    test "Recognizes Docstring with annotated type: `\"\"\"ruby`" do
      delim = "\"\"\""
      assert [{:token, :doc_string, {:location, 1, 1}, {delim, :ruby}}] == tokenize(["#{delim}ruby"])
    end
  end

  describe "#tokenize(path: _) works for all Good Feature Files" do
    __DIR__
    |> Path.join("support/testdata/good/*.feature")
    |> Path.wildcard()
    |> Enum.each(fn path ->
      file =
        path
        |> String.split()
        |> List.last()

      test "#{file}" do
        result =
          [path: unquote(path)]
          |> Scanner.tokenize()
          |> Enum.take(1000)

        assert is_list(result)
      end
    end)
  end

  describe "#tokenize(list) ignores Gherkin Keywords within Docstring" do
    @some_text "This is some text"
    @keywords
    |> Enum.each(fn {textual_syntax, keyword} ->
      test "Gherkin Keyword: `#{textual_syntax}`" do
        gherkin_keyword_content = "#{unquote(textual_syntax)} #{@some_text}"

        docstring_lines =
          """
          This is a Docstring

          All content in here is regarded as normal text
          Regardless as to Gherkin Keywords being indented:
                #{gherkin_keyword_content}

          or not
          #{gherkin_keyword_content}
          """
          |> String.split("\n")
          |> Enum.map(&(&1 <> "\n"))
          |> Kernel.++(["\"\"\""])

        ["\"\"\"" | docstring_lines]
        |> tokenize
        |> Enum.each(fn {:token, actual_keyword, _, _} ->
          assert actual_keyword != unquote(keyword)
          assert actual_keyword in [:doc_string, :string, :empty]
        end)
      end
    end)
  end

  describe "#tokenize(list) does not allow ending Docstring with a typed delim" do
    test "Starting without typed delim but ending with typed delim" do
      assert_raise SyntaxError, fn ->
        tokenize(["\"\"\"", "a\n", "\"\"\"ruby"])
      end
    end

    test "Starting and ending with typed delim" do
      assert_raise SyntaxError, fn ->
        tokenize(["\"\"\"ruby", "a\n", "\"\"\"ruby"])
      end
    end
  end
end
